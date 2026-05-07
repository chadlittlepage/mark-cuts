# mark_cuts

A tiny DaVinci Resolve script that adds a blue marker at every cut point on the current timeline, across all video tracks.

Useful for:

- Quickly visualizing edit density
- Lining up sound design / music hits to picture cuts
- Building a navigable map of edits with arrow-key marker jumps

## Requirements

- DaVinci Resolve 17 or newer (Studio or Free)
- Python 3 installed from [python.org](https://www.python.org/downloads/) (Homebrew Python is not detected by Resolve)

## Install

**1. Copy the script to Resolve's Edit scripts folder (all users):**

```bash
sudo mkdir -p "/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Edit/"
sudo cp mark_cuts.py "/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Edit/"
```

**2. Enable external scripting in Resolve:**

`Preferences` > `System` > `General` > set **External scripting using** to **Local** > `Save` > restart Resolve.

**3. Run it:**

`Edit page` > `Workspace` > `Scripts` > `Edit` > `mark_cuts`

## Usage

With a timeline open, run the script. It will:

1. Walk every video track on the current timeline
2. Collect the in/out frame of every clip
3. Drop a blue marker labeled `Cut` at each cut point
4. Skip the very first and last frame of the timeline (not real cuts)
5. Skip any frames that already have a marker, so it is safe to re-run

## Not showing up?

- Confirm Python 3 is installed from python.org (not Homebrew)
- Confirm **External scripting using** is set to **Local**
- Restart Resolve after changing the preference

## License

MIT

## Author

Chad Littlepage
chad.littlepage@gmail.com | 323.974.0444
