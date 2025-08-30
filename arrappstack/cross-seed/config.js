// /config/config.js
const enc = encodeURIComponent;
const PROWLARR_URL = process.env.PROWLARR_URL || "http://127.0.0.1:9696";
const PROWLARR_API_KEY = process.env.PROWLARR_API_KEY;
const QB_HOST = process.env.QB_HOST || "137.ftl11.seedit4.me:443/qbittorrent";
const QB_USER = process.env.QB_USER || "";
const QB_PASS = process.env.QB_PASS || "";

module.exports = {
  // search all enabled indexers via Prowlarr
  torznab: [`${PROWLARR_URL}/0/api?apikey=${PROWLARR_API_KEY}`],

  // scan ALL torrents from qBittorrent (not just categories/tags)
  useClientTorrents: true,

  // client(s)
  torrentClients: [
    `qbittorrent:https://${enc(QB_USER)}:${enc(QB_PASS)}@${QB_HOST}`
  ],

  // also allow file-based matching (optional but helpful)
  dataDirs: ["/downloads/movies", "/downloads/tv", "/downloads/adult"],
  // maxDataDepth: 3,

  // what to do when a match is found
  action: "inject",
  linkDirs: ["/downloads/cross-seed"],  // adjust perms/ownership as above
  linkType: "hardlink",


  // housekeeping
  matchMode: "safe",
  skipRecheck: false,

  // visibility in qB (doesn't FILTER; just labels injected torrents)
  tags: ["cross-seed"],
  // category: "cross-seed", // uncomment if you want a qB category too

  // daemon schedules
  rssCadence: "10 minutes",
  searchCadence: "2 days",
  excludeRecentSearch: "7 days",
  excludeOlder: "28 days"
};
