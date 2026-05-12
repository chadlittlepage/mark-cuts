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

- **DaVinci Resolve 17 or newer** — Studio *or* Free. Scripting is supported in both as of Resolve 18.
- **macOS 12 (Monterey) or newer**
- **Python 3 from [python.org](https://www.python.org/downloads/)** — Homebrew Python is not detected by Resolve, even if `python3 --version` works in your terminal.

---

## Complete first-time install (step by step)

Follow this top to bottom. Takes about 5 minutes on a fresh Mac.

### 1. Install DaVinci Resolve

Free download from [Blackmagic Design](https://www.blackmagicdesign.com/products/davinciresolve). Either Resolve or Resolve Studio works.

### 2. Install Python 3 from python.org

Resolve only detects the python.org build, **not** Homebrew Python.

1. Go to [python.org/downloads](https://www.python.org/downloads/)
2. Click the big yellow **Download Python 3.x.x** button
3. Open the downloaded `.pkg` and click through the installer (default settings are fine)
4. Verify in Terminal:
   ```bash
   ls /Library/Frameworks/Python.framework
   ```
   If that prints `Versions` or similar (not "No such file…"), you're set.

### 3. Install mark_cuts

Download **Mark_Cuts_Installer-v1.0.2.pkg** from the [latest release](https://github.com/chadlittlepage/mark-cuts/releases), then double-click it. The wizard walks you through. Signed + notarized — no Gatekeeper warning.

The installer:

- Drops `mark_cuts.py` into Resolve's system **Utility** folder (`/Library/.../Fusion/Scripts/Utility/`). One copy — Resolve shows Utility scripts at the top of `Workspace > Scripts` on **every** page (Edit, Color, Fusion, Deliver), so this single install reaches every page with no duplicates.
- Checks for Python 3 from python.org and logs a warning to `/var/log/install.log` if it's missing
- Drops `Mark_Cuts_NEXT_STEPS.txt` on your Desktop with the next two steps

### 4. Enable external scripting in Resolve

1. Open DaVinci Resolve
2. In the menu bar: **DaVinci Resolve > Preferences…**
3. Click the **System** tab, then **General** in the sidebar
4. Find **External scripting using** and set it to **Local**
5. Click **Save**
6. Quit Resolve completely (`Cmd-Q`) and re-open it

### 5. Run mark_cuts

1. Open a project that has a timeline
2. Open the timeline (click into it)
3. In the menu bar: **Workspace > Scripts > mark_cuts**
4. You should see blue **Cut** markers appear at every cut, and a confirmation in the console:
   ```
   Done - added 134 markers across 3 video track(s).
   ```

That's it. You can re-run the script any time — it skips frames that already have a marker.

---

## Quick install (already have Python 3 + Resolve scripting set up)

Three paths. Pick whichever fits.

### A — Signed .pkg installer (recommended)

Download `Mark_Cuts_Installer-v1.0.2.pkg` from the [latest release](https://github.com/chadlittlepage/mark-cuts/releases) and double-click. Done.

### B — Shell installer

```bash
git clone https://github.com/chadlittlepage/mark-cuts.git
cd mark-cuts
./install.sh
```

Prompts for your sudo password. Same end result as the .pkg: one copy in `/Library/.../Fusion/Scripts/Utility/` and a Desktop next-steps doc.

### C — Build the .pkg from source

```bash
git clone https://github.com/chadlittlepage/mark-cuts.git
cd mark-cuts
./build_pkg.sh --notarize   # signed + notarized + stapled
# or
./build_pkg.sh --sign       # signed only
# or
./build_pkg.sh              # unsigned (testing only)
```

Output lands in `build/Mark_Cuts_Installer-v<version>.pkg`.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Script doesn't appear in `Workspace > Scripts` | Quit and re-open Resolve. The scripts menu only refreshes on launch. |
| `Could not connect to DaVinci Resolve.` in the console | External scripting is not set to **Local**. Re-do step 4 above. |
| Python error like `ModuleNotFoundError` in the console | Python 3 is missing or is the wrong build. Re-do step 2 above and re-launch Resolve. |
| `Permission denied` when installing manually | Use the .pkg or `install.sh` — both handle `sudo` for you. |
| Markers go to the wrong timeline | The script always operates on `GetCurrentTimeline()`. Click into the timeline you want before running. |
| `Mark_Cuts_NEXT_STEPS.txt` keeps coming back on Desktop | It's only written on install. Delete it once you've completed steps 4-5. |

If something still doesn't work, open an [issue](https://github.com/chadlittlepage/mark-cuts/issues) with: macOS version, Resolve version, Python version (`/Library/Frameworks/Python.framework/Versions/Current/bin/python3 --version`), and what's in the Resolve console after you try to run the script.

---

## Uninstall

v1.0.2 places one file. Earlier versions placed up to ten. `uninstall.sh` removes all of them:

```bash
git clone https://github.com/chadlittlepage/mark-cuts.git
cd mark-cuts
./uninstall.sh
```

Or directly:

```bash
# v1.0.2 install location
sudo rm -f "/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Utility/mark_cuts.py"

# Legacy locations from v1.0.0 / v1.0.1 (safe to run even if not present)
sudo rm -f "/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/"{Edit,Color,Comp,Deliver}"/mark_cuts.py"
rm -f "$HOME/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/"{Utility,Edit,Color,Comp,Deliver}"/mark_cuts.py"

# Installer receipt
sudo pkgutil --forget com.chadlittlepage.mark-cuts 2>/dev/null

# Next-steps note on your Desktop
rm -f "$HOME/Desktop/Mark_Cuts_NEXT_STEPS.txt"
```

To strip the markers it added inside Resolve: filter the marker list by color **Blue** with name **Cut**, select all, and delete.

---

## Notarization setup (only needed if you're building from source)

```bash
xcrun notarytool store-credentials "chads-davinci-notary" \
    --apple-id "your-apple-id@example.com" \
    --team-id "72J767FV46" \
    --password "app-specific-password"
```

App-specific passwords are generated at [appleid.apple.com](https://appleid.apple.com) → **Sign-In and Security > App-Specific Passwords**. Then `./build_pkg.sh --notarize`.

## Project layout

```
mark_cuts/
├── mark_cuts.py            # the Resolve script
├── install.sh              # Terminal installer (mirrors the .pkg)
├── uninstall.sh            # Removes all installed copies
├── build_pkg.sh            # Builds Mark_Cuts_Installer.pkg
├── pkg/
│   ├── scripts/postinstall # Runs as root during install
│   └── resources/          # Welcome / conclusion HTML for the installer wizard
├── README.md
└── LICENSE
```

## License

MIT — see [LICENSE](LICENSE).

## Author

**Chad Littlepage**
chad.littlepage@gmail.com · 323.974.0444
