#!/usr/bin/env bash
set -e

WEBHOOK_URL=${WEBHOOK_URL:-https://webhook.site/71864ad1-0e91-4449-9759-5f9728841c85}
PING_SERVER=${PING_SERVER:-one.one.one.one}
HOST=${HOST:-Nobi}
USERNAME=${USERNAME:-admin}
PASSWORD=${PASSWORD:-admin}
GITHUB_USERNAME=${GITHUB_USERNAME:-nobiit}

if [ -z $(which cloud-init) ]; then
  sudo apt-get -qq install -y cloud-init
fi

if [ -z $(which uuidgen) ]; then
  sudo apt-get -qq install -y uuid-runtime
fi

tee user-data >>/dev/null <<-EOF
	#cloud-config
	autoinstall:
	  version: 1
	  reporting:
	    hook:
	      type: webhook
	      endpoint: ${WEBHOOK_URL}
	  early-commands:
	    - ping -c1 ${PING_SERVER}
	  late-commands:
	    - ping -c1 ${PING_SERVER}
	  locale: en_US
	  storage:
	    layout:
	      name: direct
	  identity:
	    hostname: ${HOST}
	    username: ${USERNAME}
	    password: $(printf ${PASSWORD} | openssl passwd -6 -stdin)
	  network:
	    version: 2
	    ethernets:
	      eth0:
	        optional: no
	        dhcp4: yes
	        dhcp6: yes
	    wifis:
	      wlan0:
	        optional: no
	        dhcp4: yes
	        dhcp6: yes
	        access-points:
	          "YouthDev":
	            password: "youthdev2016"
	          "Phong 2":
	            password: "22053319a"
	          "phong ngoc":
	            password: "30092008"
	          "NobiIT":
	            password: "10102000"
	      wlan1:
	        optional: no
	        dhcp4: yes
	        dhcp6: yes
	        access-points:
	          "NobiDev":
	            password: "nobidev@2016"
	  ssh:
	    install-server: true
	    authorized-keys:
	$(curl -s https://github.com/${GITHUB_USERNAME}.keys | xargs printf '      - %s %s\n')
EOF

tee meta-data >>/dev/null <<-EOF
	instance-id: $(uuidgen)
EOF

cloud-init devel schema --config-file user-data

./build.sh -a -u user-data -m meta-data

ln -sf ubuntu-autoinstall-$(date +"%Y-%m-%d").iso ubuntu-autoinstall.iso
