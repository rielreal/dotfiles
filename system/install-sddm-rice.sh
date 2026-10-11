#!/usr/bin/env bash
set -euo pipefail

user="${SUDO_USER:?run with sudo}"
user_home="$(getent passwd "$user" | cut -d: -f6)"
source_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
theme=/usr/share/sddm/themes/Rice
state=/var/lib/sddm-rice

rm -rf "$theme"
cp -r "$source_root/sddm/Rice" "$theme"
chown -R root:root "$theme"
chmod -R u=rwX,go=rX "$theme"
ln -sfn "$state/theme.conf.user" "$theme/theme.conf.user"
install -d -o "$user" -g "$user" -m 755 "$state"

install -d /usr/local/share/fonts/rubik
install -m 644 "$user_home"/.local/share/fonts/rubik/*.ttf /usr/local/share/fonts/rubik/
fc-cache -f /usr/local/share/fonts

cat > /etc/sddm.conf.d/rice.conf <<'EOF'
[Autologin]
Relogin=false
Session=
User=

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=Rice

[Users]
MaximumUid=60513
MinimumUid=1000
EOF
rm -f /etc/sddm.conf.d/the_hyde_project.conf

echo "installed SDDM theme Rice; colours are written to $state by wallpaper-colors"
