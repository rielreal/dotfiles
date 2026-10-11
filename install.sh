#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
local_dir="$repo/local"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"

install_packages() {
    local missing aur_missing helper
    mapfile -t missing < <(pacman -T $(< "$repo/packages/pacman.txt") || true)
    if ((${#missing[@]})); then
        echo "installing ${#missing[@]} packages: ${missing[*]}"
        sudo pacman -S --needed "${missing[@]}"
    fi
    mapfile -t aur_missing < <(pacman -T $(< "$repo/packages/aur.txt") || true)
    ((${#aur_missing[@]})) || return 0
    for helper in paru yay; do
        if command -v "$helper" >/dev/null; then
            "$helper" -S --needed "${aur_missing[@]}"
            return
        fi
    done
    echo "install these from the AUR yourself: ${aur_missing[*]}"
}

link_tree() {
    local source_root=$1 file relative target
    while IFS= read -r -d '' file; do
        relative="${file#"$source_root"/}"
        target="$HOME/$relative"
        mkdir -p "$(dirname "$target")"
        if [[ -e "$target" && ! -L "$target" ]]; then
            if [[ -s "$target" ]]; then
                mv "$target" "$target.pre-dotfiles"
                echo "moved existing ~/$relative to ~/$relative.pre-dotfiles"
            else
                rm "$target"
            fi
        fi
        ln -sfn "$file" "$target"
    done < <(find "$source_root" -type f -print0)
}

create_local_stubs() {
    local stub
    for stub in .config/hypr/local.conf .config/kitty/local.conf; do
        [[ -e "$HOME/$stub" ]] || : > "$HOME/$stub"
    done
}

link_gtk4_theme() {
    local gtk4="$HOME/.config/gtk-4.0"
    if [[ -e "$gtk4" && ! -L "$gtk4" ]]; then
        mv "$gtk4" "$gtk4.pre-dotfiles"
        echo "moved existing ~/.config/gtk-4.0 to ~/.config/gtk-4.0.pre-dotfiles"
    fi
    ln -sfn "$HOME/.local/share/themes/Rice/gtk-4.0" "$gtk4"
}

ensure_wallpaper() {
    local wallpaper_dir default
    [[ -e "$state_dir/wallpaper" ]] && return
    wallpaper_dir="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/Wallpapers"
    default="$wallpaper_dir/rice-default.png"
    mkdir -p "$wallpaper_dir" "$state_dir"
    [[ -e "$default" ]] || magick -size 3840x2160 radial-gradient:'#e58576'-'#140b0d' "$default"
    ln -sfn "$default" "$state_dir/wallpaper"
    echo "no wallpaper set yet, using $default (pick your own with Super+Shift+W)"
}

apply_gsettings() {
    command -v gsettings >/dev/null || return 0
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme Rice
    gsettings set org.gnome.desktop.interface icon-theme Papirus-Rice
    gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Ice
    gsettings set org.gnome.desktop.interface font-name 'Rubik 10'
    gsettings set org.gnome.desktop.interface enable-animations false
    gsettings set org.gnome.nautilus.icon-view default-zoom-level small-plus
    gsettings set org.gnome.nautilus.preferences show-directory-item-counts never
    gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true
}

[[ ${1:-} == --no-packages ]] || install_packages
link_tree "$repo/home"
if [[ -d "$local_dir" ]]; then
    link_tree "$local_dir"
    echo "applied your overrides from local/"
fi
create_local_stubs
link_gtk4_theme
fc-cache -f "$HOME/.local/share/fonts" >/dev/null
ensure_wallpaper
"$HOME/.config/hypr/scripts/wallpaper-colors" "$(readlink -f "$state_dir/wallpaper")"
apply_gsettings
echo "done"
