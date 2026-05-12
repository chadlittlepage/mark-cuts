# mark_cuts

A small DaVinci Resolve script that adds a blue marker at every cut point on the current timeline, across all video tracks. Re-runnable and non-destructive — it skips frames that already have a marker.

![Resolve](https://img.shields.io/badge/DaVinci_Resolve-17%2B-blue)
![macOS](https://img.shields.io/badge/macOS-12%2B-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## What it's for

- Visualizing edit density at a glance
- Lining up sound design, score hits, or VFX cues to picture cuts
- Building a navigable map of every edit, jumpable with arrow keys
- Spotting frame-accurate cut boundaries when audio is unreliable

## How it works

1. Walks every video track on the current timeline
2. Collects the in-point and out-point frame of every clip
3. Drops a blue marker labeled **Cut** at each unique frame
4. Skips the very first and last frame of the timeline (not real cuts)
5. Skips frames that already have a marker, so re-running is safe

Output is logged to Resolve's console:

```
Done - added 134 markers across 3 video track(s).
```

## Requirements

- **DaVinci Resolve 17 or newer** (Studio or Free)
- **Python 3 from [python.org](https://www.python.org/downloads/)** — Homebrew Python is not detected by Resolve
- **macOS 12 (Monterey) or newer** for the .pkg installer

## Install

You have three options. Pick whichever fits.

### Option 1 — Signed .pkg installer (recommended)

Download `Mark_Cuts_Installer.pkg` from the [latest release](https://github.com/chadlittlepage/mark-cuts/releases) and double-click it. The wizard walks you through installation.

Builds locally from source:

```bash
./build_pkg.sh --sign       # signed with Developer ID
./build_pkg.sh --notarize   # signed + notarized + stapled
./build_pkg.sh              # unsigned (testing only)
```

The signed pkg lands in `build/Mark_Cuts_Installer-v<version>.pkg`.

### Option 2 — Shell installer

From a clone of the repo:

```bash
./install.sh
```

You'll be prompted for your password (the script copies into `/Library/Application Support/...`). Prints next-step instructions when done.

### Option 3 — Manual

```bash
sudo mkdir -p "/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Edit/"
sudo cp mark_cuts.py "/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Edit/"
```

## After install — two manual steps

These can't be automated; they're inside DaVinci Resolve.

1. **Enable external scripting** — open Resolve, go to `Preferences > System > General`, set **External scripting using** to **Local**, click **Save**, then restart Resolve.
2. **Run the script** — open a project with a timeline, then go to `Workspace > Scripts > Edit > mark_cuts`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Script doesn't appear in `Workspace > Scripts` | Restart Resolve after install. |
| `Could not connect to DaVinci Resolve.` | External scripting is not set to **Local**. See step 1 above. |
| Python errors in the console | Python 3 must be installed from python.org. Homebrew Python is not picked up by Resolve. |
| `Permission denied` during install | Use the .pkg or `install.sh` — both handle `sudo` for you. |
| Markers added in the wrong place | Confirm the timeline has the playhead at the right project. The script always operates on `GetCurrentTimeline()`. |

## Uninstall

```bash
sudo rm "/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Edit/mark_cuts.py"
```

To strip the markers it added, in Resolve: right-click any blue **Cut** marker on the timeline ruler and choose **Delete All Markers** (or filter by color in the marker list).

## Building the .pkg from source

The build script lives at `build_pkg.sh` and uses standard macOS tools (`pkgbuild`, `productbuild`, `productsign`, `xcrun notarytool`, `xcrun stapler`). No extra dependencies.

### One-time setup for notarization

```bash
xcrun notarytool store-credentials "mark-cuts-notary" \
    --apple-id "your-apple-id@example.com" \
    --team-id "72J767FV46" \
    --password "app-specific-password"
```

App-specific passwords are generated at [appleid.apple.com](https://appleid.apple.com) under **Sign-In and Security > App-Specific Passwords**.

Then:

```bash
./build_pkg.sh --notarize
```

Notarization takes 30-120 seconds. The stapled pkg is ready for distribution with no Gatekeeper warning.

## Project layout

```
mark_cuts/
├── mark_cuts.py            # the actual Resolve script
├── install.sh              # Terminal installer
├── build_pkg.sh            # builds Mark_Cuts_Installer.pkg
├── pkg/
│   ├── scripts/postinstall # runs as root during install
│   └── resources/          # welcome/conclusion HTML for the installer wizard
├── README.md
└── LICENSE
```

## License

MIT — see [LICENSE](LICENSE).

## Author

**Chad Littlepage**
chad.littlepage@gmail.com · 323.974.0444
