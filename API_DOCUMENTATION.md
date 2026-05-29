# Apex Legends API — Documentation V2

> **Unofficial API** — No warranty. No guaranteed uptime.
> Source: [apexlegendsapi.com](https://apexlegendsapi.com) · Contact: hugo#0069 on Discord

---

## Table of Contents

- [Authentication](#authentication)
- [Rate Limiting](#rate-limiting)
- [Webhook](#webhook)
- [Platform Codes](#platform-codes)
- [Upstream API Reference](#upstream-api-reference)
  - [Player Statistics — Query by Name](#1-player-statistics--query-by-name)
  - [Player Statistics — Query by UID](#2-player-statistics--query-by-uid)
  - [Match History — New API](#3-match-history--new-api)
  - [Match History — Legacy API](#4-match-history--legacy-api)
  - [Leaderboards](#5-leaderboards)
  - [Map Rotation](#6-map-rotation)
  - [Predator](#7-predator)
  - [Server Status](#8-server-status)
  - [Origin](#9-origin)
  - [Name to UID](#10-name-to-uid)
- [Error Codes](#error-codes)
- [ApexLegendsStatus Render Proxy](#apexlegendsstatus-render-proxy)

---

## Authentication

All requests require an API key, obtained from the [developer portal](https://apexlegendsapi.com).
One API key is allowed per project/person.

**Via query parameter:**
```
GET https://api.apexlegendsstatus.com/bridge?auth=YOUR_API_KEY
```

**Via header:**
```
Authorization: YOUR_API_KEY
```

---

## Rate Limiting

- Default: **5 requests/second** across all APIs
- Can be increased by connecting your Discord account or opening a Discord ticket
- Current rate is returned in the `X-Current-Rate` response header

---

## Webhook

Match history data can be pushed to your server via webhook. Configure webhook URLs on the developer portal.

- User agent: `ApexAPI Webhook/0.1`
- Your server must accept the POST request within **3 seconds**, otherwise it is dropped
- Currently only the match history API supports webhooks

---

## Platform Codes

| Code | Platform |
| --- | --- |
| `PC` | PC (Origin or Steam) |
| `PS4` | PlayStation 4 / 5 |
| `X1` | Xbox One / Series X\|S |
| `SWITCH` | Nintendo Switch (UID queries only) |
| `ANY` | All platforms (leaderboard only) |

---

## Upstream API Reference

**Base URL:** `https://api.apexlegendsstatus.com`

---

### 1. Player Statistics — Query by Name

**GET** `/bridge`

Returns player statistics by username. For PC players use the Origin account name, even if playing on Steam.

| Parameter | Required | Description |
| --- | --- | --- |
| `player` | ✅ | Player username |
| `platform` | ✅ | `PC`, `PS4`, or `X1` (SWITCH not supported for name lookup) |
| `version` | ❌ | API version (`1`, `2`, `4`, or `5`). Default is `5` — do not use others, they are deprecated |
| `enableClubsBeta` | ❌ | `true` or `false` — attempts to return the player's clubs. Beta, may return no data |
| `skipRank` | ❌ | Any value — omits rank data from the response |
| `merge` | ❌ | Any value — merges same-type trackers (e.g. limited-edition kills → kills) |
| `removeMerged` | ❌ | Any value — removes source trackers after merging |

```
GET https://api.apexlegendsstatus.com/bridge?auth=YOUR_API_KEY&player=PLAYER_NAME&platform=PLATFORM
```

---

### 2. Player Statistics — Query by UID

**GET** `/bridge`

Same as query by name but uses a UID. Recommended for players you query repeatedly — UIDs are stable across name changes. Also supports SWITCH.

| Parameter | Required | Description |
| --- | --- | --- |
| `uid` | ✅ | Player UID |
| `platform` | ✅ | `PC`, `PS4`, `X1`, or `SWITCH` |
| `version` | ❌ | API version (`1`, `2`, `4`, or `5`). Default is `5` — do not use others |
| `enableClubsBeta` | ❌ | `true` or `false` — beta clubs data |
| `skipRank` | ❌ | Any value — omits rank data |
| `merge` | ❌ | Any value — merges same-type trackers |
| `removeMerged` | ❌ | Any value — removes merged source trackers |

```
GET https://api.apexlegendsstatus.com/bridge?auth=YOUR_API_KEY&uid=PLAYER_UID&platform=PLATFORM
```

---

### 3. Match History — New API

**GET** `/games`

🔐 **Whitelist required** — Open a Discord ticket to request access. Currently unavailable to new users.

Free to use with a strict limit of **5 unique players queried per hour**. To collect match data, you must make a `/bridge` request for the player every 4 minutes — collected data then becomes available on `/games`.

| Parameter | Required | Description |
| --- | --- | --- |
| `uid` | ✅ | Player UID |
| `mode` | ❌ | Filter by game mode: `BATTLE_ROYALE`, `ARENAS`, or `UNKNOWN` |
| `start` | ❌ | Only return matches after this epoch timestamp (int) |
| `end` | ❌ | Only return matches before this epoch timestamp (int) |
| `limit` | ❌ | Maximum number of matches to return (int) |

```
GET https://api.apexlegendsstatus.com/games?auth=YOUR_API_KEY&uid=PLAYER_UID
```

> Webhook support is available — configure on the developer portal.

---

### 4. Match History — Legacy API

**GET** `/bridge` with `history=1`

🔐 **Currently unavailable to new users.** Data collected from this API is available on both `/bridge` and `/games`. Add a player to your tracked list before querying their history.

| Parameter | Required | Description |
| --- | --- | --- |
| `uid` | ✅ | Player UID |
| `platform` | ✅ | `PC`, `PS4`, `X1`, or `SWITCH` |
| `history` | ✅ | Must be `1` to enable match history mode |
| `action` | ✅ | `info` — list tracked players · `get` — get matches · `delete` — remove player · `add` — add player |

```
GET https://api.apexlegendsstatus.com/bridge?auth=YOUR_API_KEY&uid=PLAYER_UID&platform=PLATFORM&history=1&action=ACTION
```

---

### 5. Leaderboards

**GET** `/leaderboard`

🔐 **Currently unavailable to new users.** Returns top 500 players per statistic/legend. Updated every 6 hours.

> **Attribution required:** Unless you have white-label access, you must display a direct clickable link to `https://apexlegendsstatus.com` with the text **"Data provided by Apex Legends Status"**.

| Parameter | Required | Description |
| --- | --- | --- |
| `platform` | ✅ | `PC`, `PS4`, `X1`, `SWITCH`, or `ANY` |
| `legend` | ✅ | Legend name (capital first letter). Use `Global` for global trackers, level, rankScore, arenaScore |
| `key` | ❌ | Tracker key to return. Omit to get a list of all available keys for the legend |

```
GET https://api.apexlegendsstatus.com/leaderboard?auth=YOUR_API_KEY&legend=LEGEND&key=KEY&platform=PLATFORM
```

---

### 6. Map Rotation

**GET** `/maprotation`

Returns current and next map for Battle Royale (pubs + ranked) and Arenas. Control map rotation also available.

> ⚠️ `version=1` (or no version) only returns Battle Royale pubs. Use `version=2` for all modes.

| Parameter | Required | Description |
| --- | --- | --- |
| `version` | ❌ | `1` for BR pubs only · `2` for all modes |

```
GET https://api.apexlegendsstatus.com/maprotation?auth=YOUR_API_KEY
```

---

### 7. Predator

**GET** `/predator`

Returns the RP/AP required to reach Apex Predator on PC, PlayStation, Xbox, and Switch. Also returns the number of Masters on each platform.

```
GET https://api.apexlegendsstatus.com/predator?auth=YOUR_API_KEY
```

---

### 8. Server Status

**GET** `/servers`

Returns current server status as shown on apexlegendsstatus.com.

> **Attribution required:** Display either a clickable link to `https://apexlegendsstatus.com` or the text **"Data from apexlegendsstatus.com"** when showing this data.

```
GET https://api.apexlegendsstatus.com/servers?auth=YOUR_API_KEY
```

---

### 9. Origin

**GET** `/origin`

Returns a player's UID without fetching full statistics. The player must have previously played Apex Legends. **PC / Origin only.**

| Parameter | Required | Description |
| --- | --- | --- |
| `player` | ✅ | Player username |

```
GET https://api.apexlegendsstatus.com/origin?auth=YOUR_API_KEY&player=PLAYER_NAME
```

---

### 10. Name to UID

**GET** `/nametouid`

Converts a player name to a UID. Supports PC, PlayStation, and Xbox.

| Parameter | Required | Description |
| --- | --- | --- |
| `player` | ✅ | Player username |
| `platform` | ✅ | `PS4` for PlayStation · `X1` for Xbox · `PC` for Origin |

```
GET https://api.apexlegendsstatus.com/nametouid?auth=YOUR_API_KEY&player=PLAYER_NAME&platform=PLATFORM
```

---

## Error Codes

| Code | Meaning |
| --- | --- |
| `400` | Try again in a few minutes |
| `403` | Unauthorized / unknown API key |
| `404` | Player not found |
| `405` | External API error |
| `410` | Unknown platform provided |
| `429` | Rate limit reached |
| `500` | Internal error |

---

## ApexLegendsStatus Render Proxy

A thin Express proxy that keeps the API key server-side and adds caching, rate limiting, and an outbound request queue. Deployed on Render.

**Base URL:** your Render service URL  
**Authentication:** Set `x-client-token: YOUR_CLIENT_TOKEN` header on every request (except `/healthz`)

### Architecture

| Layer | Detail |
| --- | --- |
| **Inbound rate limit** | 60 req/min per IP (`express-rate-limit`) |
| **Client token gate** | `x-client-token` header checked on all routes except `/healthz` |
| **Outbound queue** | Requests to the upstream API are spaced 200ms apart (5 req/sec max) using a chained Promise queue — no library dependency |
| **In-memory cache** | TTL cache per endpoint — resets on server restart |
| **CORS** | Locked to `ALLOWED_ORIGINS` env var in production |

### Cache TTLs

| Endpoint | TTL |
| --- | --- |
| `/maprotation` | 30 seconds |
| `/servers` | 5 minutes |
| `/predator` | 15 minutes |

### Proxy Routes

| Proxy Route | Upstream | Notes |
| --- | --- | --- |
| `GET /healthz` | — | Health check, no auth required |
| `GET /maprotation` | `/maprotation?version=2` | Always requests all modes |
| `GET /player?player=&platform=` | `/bridge` | By name; PC, PS4, X1. Optional: `skipRank`, `enableClubsBeta`, `merge`, `removeMerged` |
| `GET /player/uid?uid=&platform=` | `/bridge` | By UID; all platforms incl. SWITCH. Optional: `skipRank`, `enableClubsBeta`, `merge`, `removeMerged` |
| `GET /origin?player=` | `/origin` | PC / Origin only |
| `GET /nametouid?player=&platform=` | `/nametouid` | PC, PS4, X1 |
| `GET /servers` | `/servers` | Cached 5 min |
| `GET /predator` | `/predator` | Cached 15 min |
| `GET /leaderboard?platform=&legend=` | `/leaderboard` | Whitelist required. Optional: `key` |
| `GET /games?uid=&mode=&start=&end=&limit=` | `/games` | Whitelist required. `mode` must be `BATTLE_ROYALE`, `ARENAS`, or `UNKNOWN` |
| `GET /history?uid=&platform=&action=` | `/bridge?history=1` | Legacy match history. `action`: `info`, `get`, `delete`, `add` |

### Not Proxied

| Endpoint | Reason |
| --- | --- |
| `/crafting` | ⚠️ Obsolete — not used by this application |

### Environment Variables

| Variable | Required | Description |
| --- | --- | --- |
| `APEX_API_KEY` | ✅ | Upstream API key — never exposed to clients |
| `CLIENT_TOKEN` | ❌ | Shared secret for `x-client-token` header. Without it, any caller can use the proxy |
| `PORT` | ❌ | Server port, defaults to `3000` |
| `ALLOWED_ORIGINS` | ❌ | Comma-separated list of allowed CORS origins |

### Error Responses

The proxy never forwards raw upstream error payloads. All errors return:

```json
{ "error": "human-readable message" }
```

| Scenario | Status | Message |
| --- | --- | --- |
| Missing/invalid `x-client-token` | `401` | `unauthorized` |
| Inbound rate limit exceeded | `429` | (standard rate-limit headers) |
| Missing required parameter | `400` | Describes what is missing |
| Player not found upstream | `404` | `Player not found` |
| External API error upstream | `405` | `External API error` |
| Unknown platform upstream | `410` | `Unknown platform` |
| Upstream rate limit hit | `429` | `Rate limit reached — try again shortly` |
| Any other upstream error | `502` | `Upstream error` |
| Unexpected server error | `500` | `Internal server error` |
