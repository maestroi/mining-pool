#!/usr/bin/env bash
echo '+-----------------------------------------------+'
echo '| Nimiq pool configurator                       |'
echo '| Script made by Maestro                        |'
echo '+-----------------------------------------------+'
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo 'Assuming this directory is inside /opt/nimiq-pool!!'
echo 'Assuming the config of server is correct'
echo '+-----------------------------------------------+'
echo '| update system                                 |'
echo '+-----------------------------------------------+'
sudo apt update -y && sudo apt-get --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade && sudo apt install unzip htop openssl
echo '+-----------------------------------------------+'
echo '| config cert                                   |'
echo '+-----------------------------------------------+'
openssl req -x509 -newkey rsa:4096 -nodes -keyout mypool.key -out mypool.cer -days 365 -subj '/CN=AceMining'
echo '+-----------------------------------------------+'
echo '| install service                               |'
echo '+-----------------------------------------------+'
echo '[Unit]
Description=Nimiqs client
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=exec
WorkingDirectory=/opt/mining-pool
ExecStart=/usr/bin/node index.js --config=server.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/pool.service
echo 'start Activate daemon'
systemctl daemon-reload
systemctl start pool
systemctl enable pool
echo '+-----------------------------------------------+'
echo '| set right UFW                                 |'
echo '+-----------------------------------------------+'
ufw allow 8444
ufw allow 22