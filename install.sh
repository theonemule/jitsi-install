#!/bin/bash

# defaults 
HOSTNAME="localhost"
USERNAME="admin"
PASSWORD="password123"
EMAIL="test@example.com"

for i in "$@"
do
	case $i in
		--hostname=*)
		HOSTNAME="${i#*=}" 
		;;
		--username=*)
		USERNAME="${i#*=}"
		;;
		--password=*)
		PASSWORD="${i#*=}"
		;;
		--email=*)
		EMAIL="${i#*=}"
		;;
		*)
		;;
	esac
done


export DEBIAN_FRONTEND=noninteractive

hostnamectl set-hostname $HOSTNAME
echo "127.0.0.1 $HOSTNAME" >> /etc/hosts

curl https://download.jitsi.org/jitsi-key.gpg.key -o jitsi-key.gpg.key
gpg --output /usr/share/keyrings/jitsi-key.gpg --dearmor jitsi-key.gpg.key
rm jitsi-key.gpg.key
echo "deb [signed-by=/usr/share/keyrings/jitsi-key.gpg] https://download.jitsi.org stable/" > /etc/apt/sources.list.d/jitsi-stable.list

curl https://prosody.im/files/prosody-debian-packages.key -o prosody-debian-packages.key
gpg --output /usr/share/keyrings/prosody-keyring.gpg --dearmor prosody-debian-packages.key
rm prosody-debian-packages.key
echo "deb [signed-by=/usr/share/keyrings/prosody-keyring.gpg] http://packages.prosody.im/debian jammy main" > /etc/apt/sources.list.d/prosody.list

apt-get update

debconf-set-selections <<< "jicofo jitsi-videobridge/jvb-hostname string $HOSTNAME"
debconf-set-selections <<< "jitsi-meet-web-config jitsi-meet/cert-choice select Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate)"

apt-get install -y jitsi-meet certbot	

echo "$EMAIL" | /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh

sed -i 's/authentication = "jitsi-anonymous"/authentication = "internal_plain"/' /etc/prosody/conf.avail/$HOSTNAME.cfg.lua

tee -a /etc/prosody/conf.avail/$HOSTNAME.cfg.lua << EOF

VirtualHost "guest.$HOSTNAME"
    authentication = "anonymous"
    c2s_require_encryption = false
    modules_enabled = {
            "bosh";
            "ping";
            "pubsub";
            "speakerstats";
            "turncredentials";
            "conference_duration";
    }
EOF

sed -i "s/\/\/ anonymousdomain: 'guest.example.com',/anonymousdomain: 'guest.$HOSTNAME',/" /etc/jitsi/meet/$HOSTNAME-config.js

echo "org.jitsi.jicofo.auth.URL=XMPP:$HOSTNAME" >  /etc/jitsi/jicofo/sip-communicator.properties

eval "prosodyctl register $USERNAME $HOSTNAME $PASSWORD"

systemctl restart prosody.service jicofo.service jitsi-videobridge2.service
