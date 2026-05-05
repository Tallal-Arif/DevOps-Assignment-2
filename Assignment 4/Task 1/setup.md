# Jenkins Setup Guide

## 1. Controller Setup
1. SSH into the Jenkins Controller EC2 instance using the `dev-key.pem`.
2. Retrieve the initial admin password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`.
3. Open a browser and navigate to `http://<controller-public-ip>:8080`.
4. Paste the initial admin password.
5. Choose **Install suggested plugins**.
6. Create the first admin user with a secure password (do not use the default).
7. Go to **Manage Jenkins > Plugins > Available plugins** and install the plugins listed in `plugins.txt`.

## 2. Agent Node Setup
1. The Jenkins Agent instance is provisioned in a private subnet.
2. Go to **Manage Jenkins > Nodes > New Node**.
3. Set Node Name to `linux-agent`, Type to `Permanent Agent`.
4. **Configuration:**
   - **Number of executors:** 2
   - **Remote root directory:** `/home/ubuntu/jenkins`
   - **Labels:** `linux-agent`
   - **Usage:** Only build jobs with label expressions matching this node
   - **Launch method:** Launch agents via SSH
   - **Host:** `<agent-private-ip>`
   - **Credentials:** Add SSH Username with private key. Username: `ubuntu`, Private Key: Enter the content of `dev-key.pem` directly.
   - **Host Key Verification Strategy:** Non verifying Verification Strategy

## 3. Global Credentials Setup
Go to **Manage Jenkins > Credentials > System > Global credentials (unrestricted)** and add:
1. **AWS Credentials**: `AWS Credentials` type. ID: `aws-creds`. Enter Access Key and Secret Key.
2. **GitHub PAT**: `Secret text` type. ID: `github-pat`. Enter the GitHub Personal Access Token.
3. **SonarQube Token**: `Secret text` type. ID: `sonar-token`. Enter the SonarQube User Token (created in Task 4).
4. **Slack Webhook**: `Secret text` type. ID: `slack-webhook`. Enter the Slack Incoming Webhook URL.
5. **Docker Credentials**: `Username with password` type. ID: `docker-creds`. Enter Docker Hub credentials (optional) or configure ECR credentials.
