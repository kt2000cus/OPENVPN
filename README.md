
# OpenVPN Installer

This repository provides an automated script (`openvpninstaller.sh`) to set up an OpenVPN server on Ubuntu Desktop or Linux Server for testing and learning purposes.

## Usage

1. Upload `openvpninstaller.sh` to your Ubuntu machine.
2. Make it executable and run it:
   ```bash
   chmod +x openvpninstaller.sh
   ./openvpninstaller.sh
   ```
3. The script will install OpenVPN, generate all necessary keys and certificates, and configure the server and a sample client.

## Key and Certificate Locations

After running the script, you will find the following files:

### On the Server (`/etc/openvpn`):
- `ca.crt` — Certificate Authority public certificate
- `server.crt` — Server certificate
- `server.key` — Server private key
- `dh.pem` — Diffie-Hellman parameters
- `ta.key` — TLS authentication key
- `server.conf` — OpenVPN server configuration
- `client1.conf` — Sample client configuration (edit `YOUR_SERVER_IP` before use)

### On the Server (Easy-RSA PKI, usually `~/openvpn-ca/pki`):
- `issued/client1.crt` — Client certificate
- `private/client1.key` — Client private key

## Setting Up a Client

To configure a client, copy the following files from your server:
- `ca.crt`
- `client1.crt`
- `client1.key`
- `ta.key`
- `client1.conf` (edit `YOUR_SERVER_IP` to your server's public IP or DNS)

Place all these files in the same directory on your client device and use your OpenVPN client to connect.

---

**Note:**
- This setup is for testing and learning. For production, review and harden your configuration.
- Never share your private keys (`server.key`, `client1.key`).
