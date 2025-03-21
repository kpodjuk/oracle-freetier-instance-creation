#!/bin/bash
set -e

# Function to check if required environment variables are set
check_required_vars() {
  local missing=0
  for var in "$@"; do
    if [ -z "${!var}" ]; then
      echo "ERROR: Required environment variable $var is not set"
      missing=1
    fi
  done
  
  if [ $missing -eq 1 ]; then
    echo "Please set all required environment variables and restart the container"
    exit 1
  fi
}

# Check required environment variables
check_required_vars "OCI_CONFIG_CONTENT" "OCT_FREE_AD" "DISPLAY_NAME" "OCI_COMPUTE_SHAPE"

# Set up OCI config
mkdir -p /app/config
echo "$OCI_CONFIG_CONTENT" > /app/config/oci_config

# Set up SSH keys if not already present
if [ ! -f /app/ssh/id_rsa.pub ]; then
  mkdir -p /app/ssh
  ssh-keygen -t rsa -b 2048 -f /app/ssh/id_rsa -N ""
  echo "Generated new SSH key pair"
fi

# Create oci.env file from environment variables
cat > /app/oci.env << EOF
# OCI Configuration
OCI_CONFIG=/app/config/oci_config
OCT_FREE_AD=${OCT_FREE_AD}
DISPLAY_NAME=${DISPLAY_NAME}
OCI_COMPUTE_SHAPE=${OCI_COMPUTE_SHAPE}
SECOND_MICRO_INSTANCE=${SECOND_MICRO_INSTANCE:-False}
REQUEST_WAIT_TIME_SECS=${REQUEST_WAIT_TIME_SECS:-60}
SSH_AUTHORIZED_KEYS_FILE=/app/ssh/id_rsa.pub
OCI_SUBNET_ID=${OCI_SUBNET_ID:-}
OCI_IMAGE_ID=${OCI_IMAGE_ID:-}
OPERATING_SYSTEM=${OPERATING_SYSTEM:-Canonical Ubuntu}
OS_VERSION=${OS_VERSION:-22.04}
ASSIGN_PUBLIC_IP=${ASSIGN_PUBLIC_IP:-false}
BOOT_VOLUME_SIZE=${BOOT_VOLUME_SIZE:-50}

# Notification Configuration
NOTIFY_EMAIL=${NOTIFY_EMAIL:-False}
EMAIL=${EMAIL:-}
EMAIL_PASSWORD=${EMAIL_PASSWORD:-}
DISCORD_WEBHOOK=${DISCORD_WEBHOOK:-}
EOF

# Function to clean up and send notification
cleanup() {
  echo "Container stopping, cleaning up..."
  if [ -n "$SCRIPT_PID" ]; then
    kill $SCRIPT_PID 2>/dev/null || true
  fi
  exit 0
}

# Set up trap to catch signals
trap cleanup SIGTERM SIGINT

echo "Starting OCI instance creation script..."
cd /app

# Run the Python program
python main.py &
SCRIPT_PID=$!

# Function to check if the script is still running
is_script_running() {
  if ps -p $SCRIPT_PID > /dev/null; then
    return 0
  else
    return 1
  fi
}

# Monitor the script
while is_script_running; do
  sleep 60
done

echo "OCI instance creation script has completed"

# Keep container running
tail -f /dev/null
