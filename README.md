# rice

Hyprland desktop for Arch Linux where the whole system takes its colours from the current wallpaper. Pick a wallpaper and the bar, launcher, notifications, terminal, lock screen, GTK and Qt apps, folder icons and btop recolour to match, along with the login screen, Firefox, VS Code, IntelliJ, Telegram, Vesktop and Spotify (Spicetify) when you have them installed.

## What's in it

| Part | Program |
| --- | --- |
| Compositor | Hyprland (started through uwsm) |
| Bar | Waybar |
| Launcher, clipboard, power menu, wallpaper picker | Rofi |
| Notifications | dunst |
| Volume / brightness pop-up | SwayOSD |
| Terminal | kitty + zsh + starship |
| Lock screen / idle | hyprlock / hypridle |
| Wallpaper | awww |
| Screenshots | grim + slurp + satty |
| File manager | Nautilus |
| GTK / Qt theme | generated `Rice` theme (GTK) + Kvantum `Rice` (Qt) |
| Icons / cursor / font | Papirus with recoloured folders, Bibata Modern Ice, Rubik |

## Install

1. Clone and run the installer:

   ```sh
   git clone https://github.com/rielreal/dotfiles ~/dotfiles
   ~/dotfiles/install.sh
   ```

   It installs any missing packages from `packages/` (asks for your password; the two AUR ones need `paru` or `yay`), then symlinks everything in `home/` into your home folder. Any file it would replace is kept as `<name>.pre-dotfiles`. If you have no wallpaper yet it makes a placeholder gradient, then generates every colour file. Use `--no-packages` to skip the package step.

2. Log out and pick **Hyprland (uwsm-managed)** at the login screen.

3. Put wallpapers in `~/Pictures/Wallpapers` and press `Super+Shift+W` to pick one.

Run `install.sh` again any time; it is safe to repeat.

### Optional: login screen

```sh
sudo ~/dotfiles/system/install-sddm-rice.sh
```

Installs the `Rice` SDDM theme and makes it the active one. After that, every wallpaper change also updates the login screen.

## How the colours work

`~/.config/hypr/scripts/wallpaper-colors <image>` samples the image, builds a small palette (base, petal, ember, gold, blush, text, muted, wine) and writes it into every app's config. The wallpaper picker runs it for you. Apps that only read colours at startup (Firefox, IntelliJ, Qt apps) need a restart to pick up a new palette.

Generated files live outside the repo, mostly in `~/.local/state/rice/`. Edit the sources here, never the generated files.

- `templates/` holds the Rose Pine GTK and Kvantum themes that get recoloured.
- `home/.config/rice/` holds the Firefox, IntelliJ and Telegram templates.
- Telegram cannot load a theme on its own: paste `~/.local/state/rice/Rice.tdesktop-theme` into Saved Messages, click it and press Apply.

## Your own tweaks

Put machine-specific settings in files the shared config loads last:

| File | For |
| --- | --- |
| `~/.config/hypr/local.conf` | monitors, keyboard layout, extra binds, rules, autostart |
| `~/.config/kitty/local.conf` | kitty extras |
| `~/.config/zsh/local.zsh` | aliases, plugins |
| `~/.config/zsh/local.zshenv` | environment variables, `PATH` |

The easiest way to keep them is a `local/` folder in the repo, laid out like `home/` (for example `local/.config/hypr/local.conf`). Git ignores it, so it never gets uploaded, and `install.sh` links it after `home/` so it overrides the shared files.

## Keybinds

`Super+/` shows every bind in a searchable list.

| Keys | Action |
| --- | --- |
| `Super+T` | terminal |
| `Super+Alt+T` | dropdown terminal |
| `Super+E` | file manager |
| `Super+B` | default web browser |
| `Super+C` | VS Code |
| `Super+A` | app launcher |
| `Super+Tab` | window switcher |
| `Super+Shift+E` | file finder |
| `Super+V` / `Super+Shift+V` | clipboard history / manage clipboard |
| `Super+Shift+W` | pick wallpaper |
| `Super+Shift+C` | colour picker |
| `Super+P` | screenshot a region |
| `Super+Ctrl+P` | screenshot a region on a frozen screen |
| `Super+Alt+P` | screenshot the monitor |
| `Super+Shift+P` | edit the last screenshot |
| `Super+N` | show the last notification again |
| `Super+Esc` | power menu |
| `Super+L` | lock |
| `Ctrl+Shift+Esc` | btop |
| `Super+Q` / `Alt+F4` | close window |
| `Super+W` | toggle floating |
| `Shift+F11` | fullscreen |
| `Super+G` | group windows |
| `Super+J` | toggle split |
| `Super+S` / `Super+Shift+S` | scratchpad / move window to scratchpad |
| `Super+1`…`0` | go to workspace |
| `Super+Shift+1`…`0` | move window to workspace |
| `Super+Alt+1`…`0` | move window to workspace without following it |
| `Super+Arrows` | move focus |
| `Super+Shift+Arrows` | resize |
| `Super+Shift+Ctrl+Arrows` | move window |
| `Super+K` | next keyboard layout |

## Layout

```
home/       linked into ~ by install.sh
local/      your own overrides, git-ignored, linked after home/
templates/  theme sources the colour script recolours
system/     optional root-level pieces (SDDM theme)
packages/   pacman and AUR package lists
```

## Credits

- [Rosé Pine](https://rosepinetheme.com) GTK and Kvantum themes, used as recolour templates
- Sugar Candy SDDM theme by Marian Arlt, the base of the login screen
- JetBrains Islands Dark theme, the base of the IntelliJ theme
- Telegram Desktop's default palette from [desktop-app/lib_ui](https://github.com/desktop-app/lib_ui), the base of the Telegram theme
- [Rubik](https://fonts.google.com/specimen/Rubik) font (SIL Open Font License)
