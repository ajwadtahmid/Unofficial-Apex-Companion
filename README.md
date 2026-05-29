# Unofficial Apex Companion

<p align="center">
  <img src="assets/logos/icon_1024.png" alt="Unofficial Apex Companion" width="96" />
</p>

<p align="center">
  <strong>Know the map. Track your grind. Get alerts. Your Apex sidekick.</strong><br/>
</p>

<p align="center">
  <img alt="Release" src="https://img.shields.io/github/v/release/ajwadtahmid/Unofficial-Apex-Companion?color=orange&label=release" />
  <img alt="Build Status" src="https://img.shields.io/github/actions/workflow/status/ajwadtahmid/Unofficial-Apex-Companion/build-release.yml?branch=main&logo=github" />
  <img alt="Downloads" src="https://img.shields.io/github/downloads/ajwadtahmid/Unofficial-Apex-Companion/total?color=blue" />
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&logoColor=white" />
  <img alt="License" src="https://img.shields.io/badge/license-GPL--3.0-green" />
  <img alt="Android" src="https://img.shields.io/badge/Android-supported-brightgreen?logo=android&logoColor=white" />
  <img alt="iOS" src="https://img.shields.io/badge/iOS-supported-brightgreen?logo=apple&logoColor=white" />
  <img alt="Windows" src="https://img.shields.io/badge/Windows-supported-brightgreen?logo=windows11&logoColor=white" />
  <img alt="Linux" src="https://img.shields.io/badge/Linux-supported-brightgreen?logo=linux&logoColor=white" />
</p>

---

## Overview

Whether you're climbing ranked, managing multiple legends, or optimizing your queue, **Unofficial Apex Companion** delivers the data that matters—instantly, with zero friction.

## Table of Contents

- [Key Features](#key-features)
- [Screenshots](#screenshots)
- [Features](#features)
- [Installation](#installation)
- [Development](#development)
- [Data & Privacy](#data--privacy)
- [Known Limitations](#known-limitations)
- [FAQ](#faq)
- [Credits & Acknowledgments](#credits--acknowledgments)
- [License](#license)

---

### Key Features

- **Know the Map** — See which map is active now and preview upcoming rotations. Get instant notifications before the map changes so you're never caught off-guard mid-game.

- **Track Your Grind** — Look up any player's rank and legend statistics. Visualize your weekly RP gains with interactive graphs and compare head-to-head performance with other players across ranked seasons and splits.

- **Favorite Players & Compare** — Add players to your favorites and track their RP progression in real-time. Compare your stats side-by-side with favorited players to monitor competition and benchmark your climb.

- **Detailed Legend Stats** — Deep-dive into legend performance with advanced metrics including damage per kill, win rate, revive rate, and more custom stats. Analyze what's working and optimize your legend pool.

- **Get Alerts** — Receive instant notifications for map rotations so you never miss your favorite map.

- **Server Status** — Check latency across regions at a glance.

- **Fast & Simple** — No sign-ups, no waiting. Just instant access to the competitive data you need.


> **Disclaimer:** Unofficial fan project. Not made by, affiliated with, or endorsed by Electronic Arts or Respawn Entertainment. Apex Legends is a trademark of Electronic Arts Inc.

---

## Screenshots

| Home | Stats | Search | Settings |
|------|-------|--------|----------|
| ![Home](assets/screenshots/desktop/desktop_home.png) | ![Stats](assets/screenshots/desktop/desktop_stats.png) | ![Search](assets/screenshots/desktop/desktop_search.png) | ![Settings](assets/screenshots/desktop/desktop_settings.png) |

---

## Features

- **Player Stats** — Rank, RP, current legend, equipped trackers, and weekly RP gain tracking. Supports search by name or numeric UID.
- **Weekly Ranked History** — Interactive graph showing RP gains per week with season/split selector dropdown and week-by-week navigation (W1, W2, W3...). Tracks unlimited snapshots for power users playing 10+ matches daily.
- **Legend Stats** — Kill counts and tracker values per legend, merged across sessions and sorted by most-played.
- **Map Rotations** — Live countdown for Ranked, Pubs, and Mixtape. Shows current map, time remaining, and what loads next. Switches automatically when the rotation changes.
- **Predator Cutoff** — Current minimum RP to reach Apex Predator on PC, PlayStation, Xbox, and Switch.
- **Server Status** — Health of Origin Login, EA Accounts, Nova Fusion, and Apex Crossplay. Drill down to see per-region latency in milliseconds, color-coded green/orange/red.
- **Latest News** — In-game news feed from the official Apex feed.
- **Player Compare** — Side-by-side comparison of ranked stats or per-legend trackers with any searched player.
- **Favorites** — Star players to pin them to the search screen for one-tap access.
- **Multiple Player Profiles** — Manage and quickly switch between different player profiles. Perfect for tracking friends, alternate accounts, or monitoring competition.
- **Map Rotation Alerts** — Get notified 5, 10, or 15 minutes before the map changes in-game. Choose which maps to be notified about (ranked, pubs, mixtape).
- **Selective Mode Tracking** — Choose which modes to monitor: Ranked, Pubs, Mixtape.
- **Background Notifications** — Alerts fire even when the app is closed (via background fetch on iOS/Android).
- **View Cached Stats Offline** — All player stats are cached locally on your device. Search for a player online, and their stats remain accessible even without internet—perfect for checking during downtime.
- **No account required** — Data is fetched using your public in-game name or UID.
- **Dark theme** — Designed for low-light gaming sessions.

---

## Installation

### Android

Download from Google Play (coming soon) or the latest or `.aab` from the [Releases](../../releases) page.

### iOS

Download from the App Store (coming soon).

### Windows

1. Download `unofficial-apex-companion-installer.exe` from [Releases](../../releases)
2. Run the installer and follow the wizard
3. Launch from the Start Menu or Desktop shortcut

### Linux

1. Download `unofficial-apex-companion-*.AppImage` from [Releases](../../releases)
2. Make executable and run:

   ```bash
   chmod +x unofficial-apex-companion-*.AppImage
   ./unofficial-apex-companion-*.AppImage
   ```

---

## Development

### Requirements

| Tool | Version |
|------|---------|
| Flutter SDK | 3.x (stable channel) |
| Dart SDK | bundled with Flutter |
| Android: Java | 17 |
| iOS/macOS: Xcode | 15+ |
| Linux: GTK | `libgtk-3-dev` |

### Quick Start

```bash
# 1. Clone
git clone https://github.com/ajwadtahmid/Unofficial-Apex-Companion.git
cd Unofficial-Apex-Companion

# 2. Install dependencies
flutter pub get

# 3. Set up environment (see Configuration below)
cp .env.example .env
# edit .env with your values

# 4. Generate env code
dart run build_runner build --delete-conflicting-outputs

# 5. Run
flutter run
```

### Configuration

The app proxies all API calls through a private server — it never calls the Apex API directly. Credentials are stored in a `.env` file and compiled into the binary using [envied](https://pub.dev/packages/envied) (XOR-obfuscated at build time, not plain text in the binary).

```env
# .env
PROXY_URL=https://your-proxy-server.example.com
CLIENT_TOKEN=your-secret-token
```

After editing `.env`, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> `lib/env/env.g.dart` is generated and gitignored. The app will not compile without it.

### Project Structure

```
lib/
├── constants/         # Shared constants (API keys, pref keys, rank ladder)
├── env/               # Generated environment variables (gitignored)
├── models/            # Data models (PlayerStats, MapRotation, ServerStatus…)
├── providers/         # Riverpod providers and state notifiers
├── screens/           # One folder per tab (home, stats, search, settings)
├── services/          # API service, notification service, background service
├── utils/             # Formatters, cache, storage, theme helpers
└── widgets/           # Reusable UI components
```

### Building for Release

```bash
# Android (App Bundle for Play Store)
flutter build appbundle --release

# Android (standalone APK)
flutter build apk --release --split-per-abi

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# Linux (AppImage is packaged by CI)
flutter build linux --release
```

### CI / GitHub Actions

Pushing a tag matching `v*` triggers the release workflow, which:

1. Builds for Android (AAB), Windows, and Linux in parallel
2. Packages the Linux build as an AppImage
3. Builds the Windows NSIS installer
4. Creates a GitHub Release and attaches all artifacts

---

## Data & Privacy

- **No login, no account.** All data is public (player stats are visible on apexlegendsstatus.com).
- **No analytics or tracking.** The app does not collect or send any user data.
- **Local-only storage.** Cached responses and snapshots are stored on-device only.

Data is sourced from [apexlegendsstatus.com](https://apexlegendsstatus.com) and [apexlegendsapi.com](https://apexlegendsapi.com).

---

## Credits & Acknowledgments

Special thanks to:

- **[Hugo Derave](https://github.com/HugoDerave)** — Developer and maintainer of the [Unofficial Apex Legends API](https://apexlegendsapi.com/), which powers player stats lookups, map rotation data, and server status for this app
- **[Apex Legends Status](https://apexlegendsstatus.com/)** — Provides real-time server status, map rotation data, and players stats with comprehensive ranked stats, leaderboard for ranked along with all trackers and so much more

This project would not be possible without these amazing resources and the developer behind them.

---

## Known Limitations

- **RP snapshots** — Only tracks if app is open and sync is completed. RP gains when app is closed are not captured.
- **Legend stats** — Tracker names and values are as reported by the Apex Legends API; custom or seasonal tracker names may not be fully supported.
- **Predator cutoff** — Updates when you fetch it. Doesn't refresh automatically; manual refresh required to see latest cutoff.
- **Offline player search** — If a player hasn't been searched before, their data won't be cached and you'll need internet to look them up.

---

## FAQ

**Q: Is this app affiliated with Respawn/EA?**
No, this is an unofficial fan project. This app is not affiliated with Respawn or EA in any way. This just uses the API provided by apexlegendsapi.com to display player stats, map information, and other game data.

**Q: How often is player data updated?**
Player stats are fetched fresh from the API when you search. Cached data is available offline but may be stale.

**Q: Will my account be compromised?**
The app doesn't store your account credentials. You only provide a player name or UID, which are public information visible on apexlegendsstatus.com.

**Q: Can I track multiple players at once?**
Yes, add players to favorites for quick access. You can also compare stats with any player.

**Q: How reliable is the API?**
The app depends on [apexlegendsapi.com](https://apexlegendsapi.com/) and [apexlegendsstatus.com](https://apexlegendsstatus.com/). These services are community-run and may experience occasional downtime. The app gracefully falls back to cached data when APIs are unavailable.

**Q: What platforms are supported?**
Android, iOS, Windows, and Linux.

**Q: Do I need to create an account?**
No. Just search for any public player by name or UID.

---

## License

[GNU General Public License v3.0](LICENSE)

---

*This project is rebranded from [Apex Legends Nexus](https://github.com/ajwadtahmid/ApexLegendsNexus).*
