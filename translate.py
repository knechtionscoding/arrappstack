#!/usr/bin/env python3
import argparse
import re
import shutil
from pathlib import Path
import os
import sys

VIDEO_EXTS = {".mp4", ".mkv", ".avi", ".mov", ".m4v"}
SUBTITLE_EXTS = {".srt", ".ass", ".vtt", ".sub", ".idx"}
AUX_EXTS = {".nfo", ".vsmeta"}

QUALITY_PATTERNS = [
    r"2160p", r"1080p", r"720p", r"480p", r"360p", r"SD", r"HD",
    r"bluray", r"webrip", r"web-dl", r"hdtv", r"dvdrip"
]

EPISODE_NUMBER_RE = re.compile(r"^\s*(\d+)\b")  # leading number
SEASON_IN_FOLDER_RE = re.compile(r"season\s*(\d+)", re.IGNORECASE)


def parse_args():
    p = argparse.ArgumentParser(
        description="Reformat 'Top Gear/Top Gear Season 1/01.mp4' to Sonarr import layout."
    )
    p.add_argument("--source", "-s", type=Path, required=True, help="Root source folder (e.g. 'Top Gear')")
    p.add_argument("--dest", "-d", type=Path, required=True, help="Destination root (e.g. '/import')")
    p.add_argument("--show-name", default="Top Gear", help="Series name (default: Top Gear)")
    p.add_argument("--default-quality", default="480p", help="Default quality tag if none detected")
    p.add_argument("--mode", choices=["copy", "move", "hardlink", "symlink"], default="copy")
    p.add_argument("--include-aux", action="store_true", help="Include aux files like .vsmeta/.nfo")
    p.add_argument("--dry-run", action="store_true", help="Print actions only")
    p.add_argument("--verbose", "-v", action="store_true", help="Verbose output")
    return p.parse_args()


def log(msg, verbose=False):
    if verbose:
        print(msg)


def parse_season(folder_name: str) -> int | None:
    m = SEASON_IN_FOLDER_RE.search(folder_name)
    if m:
        try:
            return int(m.group(1))
        except ValueError:
            return None
    digits = re.findall(r"(\d+)", folder_name)
    return int(digits[0]) if digits else None


def parse_episode_num(file_stem: str) -> int | None:
    m = EPISODE_NUMBER_RE.match(file_stem)
    return int(m.group(1)) if m else None


def detect_quality(filename: str) -> str | None:
    for q in QUALITY_PATTERNS:
        if re.search(q, filename, re.IGNORECASE):
            return q
    return None


def ensure_dir(path: Path, dry_run: bool, verbose: bool):
    if not path.exists():
        log(f"[mkdir] {path}", verbose)
        if not dry_run:
            path.mkdir(parents=True, exist_ok=True)


def place_file(src: Path, dst: Path, mode: str, dry_run: bool, verbose: bool):
    ensure_dir(dst.parent, dry_run, verbose)

    if dst.exists():
        try:
            if src.stat().st_size == dst.stat().st_size:
                log(f"[skip exists same-size] {dst}", verbose)
                return
        except FileNotFoundError:
            pass
        log(f"[overwrite] {dst}", verbose)

    log(f"[{mode}] {src} -> {dst}", verbose=True)

    if dry_run:
        return

    if mode == "copy":
        shutil.copy2(src, dst)
    elif mode == "move":
        shutil.move(str(src), str(dst))
    elif mode == "hardlink":
        if dst.exists():
            dst.unlink()
        os.link(src, dst)
    elif mode == "symlink":
        if dst.exists() or dst.is_symlink():
            dst.unlink()
        os.symlink(src, dst)


def should_include(path: Path, include_aux: bool) -> bool:
    ext = path.suffix.lower()
    if ext in VIDEO_EXTS or ext in SUBTITLE_EXTS:
        return True
    if include_aux and ext in AUX_EXTS:
        return True
    return False


def build_dest_path(dest_root: Path, show_name: str, season_num: int, episode_num: int, ext: str, quality: str) -> Path:
    season_folder = f"Season {season_num:02d}"
    filename = f"{show_name} - S{season_num:02d}E{episode_num:02d} - {quality}{ext}"
    return dest_root / show_name / season_folder / filename


def main():
    args = parse_args()
    source = args.source.expanduser().resolve()
    dest = args.dest.expanduser().resolve()

    if not source.exists() or not source.is_dir():
        print(f"ERROR: Source folder not found: {source}", file=sys.stderr)
        sys.exit(1)

    # Example: source = "Top Gear", children = "Top Gear Season 1", "Top Gear Season 2"...
    for season_dir in sorted(source.iterdir()):
        if not season_dir.is_dir():
            continue

        season_num = parse_season(season_dir.name)
        if season_num is None:
            print(f"WARNING: Skipping unrecognized season folder: {season_dir}", file=sys.stderr)
            continue

        for path in sorted(season_dir.iterdir()):
            if not path.is_file():
                continue
            if not should_include(path, include_aux=args.include_aux):
                continue

            ep = parse_episode_num(path.stem)
            if ep is None:
                print(f"WARNING: Skipping file without leading episode number: {path.name}", file=sys.stderr)
                continue

            quality = detect_quality(path.name) or args.default_quality
            target = build_dest_path(dest, args.show_name, season_num, ep, path.suffix.lower(), quality)
            place_file(path, target, args.mode, args.dry_run, args.verbose)

    print("Done." + (" (dry-run)" if args.dry_run else ""))


if __name__ == "__main__":
    main()
