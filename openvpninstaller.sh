#!/bin/bash
# filepath: openvpninstaller.sh

set -e

# Variables
EASYRSA_DIR=~/openvpn-ca
SERVER_NAME=server
CLIENT_NAME=client1

echo "Updating package list and installing OpenVPN and Easy-RSA..."
sudo apt update
sudo apt install -y openvpn easy-rsa

echo "Setting up Easy-RSA directory..."
make-cadir $EASYRSA_DIR
cd $EASYRSA_DIR

echo "Initializing PKI..."
./easyrsa init-pki

echo "Building CA (you will be prompted for a password and Common Name)..."
./easyrsa --batch build-ca nopass

echo "Generating server certificate and key..."
./easyrsa gen-req $SERVER_NAME nopass
./easyrsa sign-req server $SERVER_NAME <<EOF
yes
EOF

echo "Generating Diffie-Hellman parameters..."
./easyrsa gen-dh

echo "Generating HMAC key..."
openvpn --genkey --secret ta.key

echo "Generating client certificate and key..."
./easyrsa gen-req $CLIENT_NAME nopass
./easyrsa sign-req client $CLIENT_NAME <<EOF
yes
EOF

echo "Copying certificates and keys to /etc/openvpn..."
sudo cp pki/ca.crt pki/issued/$SERVER_NAME.crt pki/private/$SERVER_NAME.key pki/dh.pem ta.key /etc/openvpn/

echo "Copying sample server.conf..."
MINIMAL_CONF="port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp.txt
keepalive 10 120
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
verb 3
explicit-exit-notify 1
"
echo "$MINIMAL_CONF" | sudo tee /etc/openvpn/server.conf > /dev/null
echo "A minimal config has been created at /etc/openvpn/server.conf. Please review it."

echo "Enabling IP forwarding..."
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

echo "Allowing OpenVPN port through UFW..."
sudo ufw allow 1194/udp

echo "Starting and enabling OpenVPN server..."
sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server

echo "OpenVPN server installation and basic setup complete!"
echo "You can find your client certificate and key in $EASYRSA_DIR/pki/issued/$CLIENT_NAME.crt and $EASYRSA_DIR/pki/private/$CLIENT_NAME.key"
