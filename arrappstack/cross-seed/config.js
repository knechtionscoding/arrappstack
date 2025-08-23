// cross-seed uses CommonJS config; envs come from docker-compose
const PROWLARR_URL = process.env.PROWLARR_URL || "http://127.0.0.1:9696";
const PROWLARR_API_KEY = process.env.PROWLARR_API_KEY;

const QB_HOST = process.env.QB_HOST || "127.0.0.1:8080";
const QB_USER = process.env.QB_USER || "";
const QB_PASS = process.env.QB_PASS || "";

module.exports = {
  // v6 style
  torznab: [
    `${PROWLARR_URL}/0/api?apikey=${PROWLARR_API_KEY}` // all indexers via /0
    // or specific ones: `${PROWLARR_URL}/1/api?apikey=${PROWLARR_API_KEY}`,
  ],
  torrentClients: [
    `qbittorrent:http://${QB_USER}:${QB_PASS}@${QB_HOST}`
  ],

  // the rest of your normal settings
  dataDirs: ["/data/torrents/movies", "/data/torrents/series"],
  linkDirs: ["/data/torrents/cross-seed"],
  linkType: "hardlink",
  matchMode: "safe",
  tags: ["cross-seed"],
  skipRecheck: false
};
