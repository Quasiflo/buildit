#!/usr/bin/env bash
echo "Fixing permissions on mounted volumes & folders ..."
sudo chown -R "$(whoami)" /mnt/mise-data /home/vscode/.local /cmdhistory # These directories needs to be owned to be editable without root access

echo "Post-create setup finished."
