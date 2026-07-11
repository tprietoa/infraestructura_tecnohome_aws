#!/bin/bash
set -xe

dnf update -y
dnf install -y docker amazon-cloudwatch-agent mariadb105 stress-ng sysstat procps-ng

systemctl enable --now docker
usermod -aG docker ec2-user
mkdir -p /usr/libexec/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/libexec/docker/cli-plugins/docker-compose
chmod +x /usr/libexec/docker/cli-plugins/docker-compose

cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'CWEOF'
{
  "agent": { "metrics_collection_interval": 60 },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}",
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}"
    },
    "aggregation_dimensions": [["AutoScalingGroupName"], ["AutoScalingGroupName", "path"]],
    "metrics_collected": {
      "mem":  { "measurement": ["mem_used_percent"] },
      "disk": { "measurement": ["used_percent"], "resources": ["/"] }
    }
  }
}
CWEOF
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

aws ecr get-login-password --region ${aws_region} | \
  docker login --username AWS --password-stdin ${ecr_registry}

cat > /home/ec2-user/.env <<ENVEOF
DB_HOST=${db_host}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
ENVEOF

cat > /home/ec2-user/docker-compose.yml <<'DCEOF'
services:
  frontend:
    image: ${ecr_registry}/tecnohome-frontend:latest
    restart: unless-stopped
    ports:
      - "80:80"
    depends_on:
      - backend
  backend:
    image: ${ecr_registry}/tecnohome-backend:latest
    restart: unless-stopped
    ports:
      - "3001:3001"
    environment:
      - DB_HOST=${db_host}
      - DB_USER=${db_user}
      - DB_PASSWORD=${db_password}
      - DB_NAME=${db_name}
DCEOF

cd /home/ec2-user && docker compose --env-file .env up -d
