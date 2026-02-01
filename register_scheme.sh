#!/bin/bash
# Create a temporary desktop entry for development
mkdir -p ~/.local/share/applications
cat <<EOF > ~/.local/share/applications/co_rider.desktop
[Desktop Entry]
Name=CoRider
Exec=/home/an/development/flutter/bin/flutter run -d linux
Type=Application
Terminal=true
MimeType=x-scheme-handler/io.supabase.flutter;
EOF

# Update shared mime info database to recognize the scheme
update-desktop-database ~/.local/share/applications

# Set default handler
xdg-mime default co_rider.desktop x-scheme-handler/io.supabase.flutter

echo "Registered io.supabase.flutter scheme to CoRider"
