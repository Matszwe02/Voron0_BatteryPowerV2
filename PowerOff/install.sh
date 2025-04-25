#!/bin/bash

SYSTEMDDIR="/etc/systemd/system"
FORCE_DEFAULTS="${FORCE_DEFAULTS:-n}"
MOONRAKER_ASVC=~/printer_data/moonraker.asvc


SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/. && pwd )"
CMD="python ${SRCDIR}/main.py"

# Create systemd service file
SERVICE_FILE="${SYSTEMDDIR}/PowerOff.service"
[ -f $SERVICE_FILE ] && [ $FORCE_DEFAULTS = "n" ]
# report_status "Installing system start script..."
sudo /bin/sh -c "cat > ${SERVICE_FILE}" << EOF
#Systemd service file for PowerOff
[Unit]
Description=V0 Battery power manager
After=network-online.target moonraker.service

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$SRCDIR
ExecStart=$CMD
# Restart=always
# RestartSec=10
EOF
# Use systemctl to enable the klipper systemd service script
sudo systemctl enable PowerOff.service
sudo systemctl daemon-reload

if [ -f $MOONRAKER_ASVC ]; then
    echo "moonraker.asvc was found"
    if ! grep -q PowerOff $MOONRAKER_ASVC; then
        echo "moonraker.asvc does not contain 'PowerOff'! Adding it..."
        echo -e "\nPowerOff" >> $MOONRAKER_ASVC
    fi
fi

sudo systemctl start PowerOff