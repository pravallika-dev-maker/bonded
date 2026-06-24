# Bonded Backend Deployment Guide

This guide outlines the step-by-step procedure for deploying or updating the FastAPI backend on an Amazon Linux EC2 server. Following these steps ensures a clean, reproducible deployment every time.

---

## 1. Connect to the EC2 Server
Use your PEM key to SSH into the EC2 server from your local machine.
```bash
ssh -i "path/to/dev-server-2.pem" ec2-user@<EC2_IP_ADDRESS>
```

## 2. Server Preparation (First-time setup only)
If this is a brand new server, you must install Git and Nginx first:
```bash
sudo dnf update -y
sudo dnf install -y git nginx
```

## 3. Clone or Update the Code
Navigate to the home directory and pull the latest code from your public GitHub repository.

**For a completely fresh deployment:**
```bash
cd ~
git clone https://github.com/pravallika-dev-maker/bonding_backend.git bonded-backend
cd bonded-backend
```

**For updating an existing deployment:**
```bash
cd ~/bonded-backend
git pull origin main
```

## 4. Set Up Python Virtual Environment
We use a virtual environment (`venv`) to isolate the backend's Python dependencies.
```bash
# Create the virtual environment (only needed once)
python3 -m venv venv

# Activate it and install requirements
source venv/bin/activate
pip install -r requirements.txt
deactivate
```

## 5. Configure Environment & Credentials
The server needs your environment variables (`.env`) and Firebase credentials. Since these are not stored in Git for security reasons, they must be copied over securely from your local machine to `/home/ec2-user/bonded-backend/`.

**Run this on your LOCAL machine:**
```bash
# Copy firebase credentials
scp -i "path/to/dev-server-2.pem" firebase-credentials.json ec2-user@<EC2_IP_ADDRESS>:/home/ec2-user/bonded-backend/

# Copy your local remote.env file as .env
scp -i "path/to/dev-server-2.pem" remote.env ec2-user@<EC2_IP_ADDRESS>:/home/ec2-user/bonded-backend/.env
```
> **Note:** Make sure your `.env` file contains the correct production `DATABASE_URL` for your RDS instance!

## 6. Configure Systemd Service (First-time setup only)
To ensure the backend runs continuously and restarts if the server reboots, we use a system daemon.

Create the service file:
```bash
sudo nano /etc/systemd/system/bonded-backend.service
```

Paste the following configuration:
```ini
[Unit]
Description=Bonded FastAPI Backend
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/bonded-backend
Environment="PATH=/home/ec2-user/bonded-backend/venv/bin"
ExecStart=/home/ec2-user/bonded-backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8001
Restart=always

[Install]
WantedBy=multi-user.target
```

## 7. Restart the Backend Service
Whenever you pull new code or change the `.env` file, you must restart the backend service for the changes to take effect.
```bash
# Reload the daemon if you edited the service file above
sudo systemctl daemon-reload

# Enable to start on boot
sudo systemctl enable bonded-backend

# Restart the service
sudo systemctl restart bonded-backend

# Check the status to ensure it says "active (running)"
sudo systemctl status bonded-backend
```

## 8. AWS Security Group Rules
Ensure your AWS EC2 Security Group has an **Inbound Rule** that allows traffic to port `8001`.
- **Type:** Custom TCP
- **Port range:** 8001
- **Source:** Anywhere-IPv4 (`0.0.0.0/0`)

## 9. Verification
Your backend should now be live! You can verify the deployment by visiting the interactive docs in your browser:
**`http://<EC2_IP_ADDRESS>:8001/docs`**
