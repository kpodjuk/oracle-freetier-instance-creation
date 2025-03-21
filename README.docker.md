# OCI Free Tier Instance Creation - Docker Container

This repository provides a containerized solution for automating the creation of Oracle Cloud Infrastructure (OCI) free tier instances. The container will continuously attempt to create instances based on your configuration and will automatically restart in case of failure or system reboot.

## Features

- Fully containerized solution
- Automatic restart on failure or system reboot
- Persistent storage for configuration, SSH keys, and logs
- Support for both VM.Standard.A1.Flex and VM.Standard.E2.1.Micro instances
- Notification support via Email and Discord

## Prerequisites

- Docker and Docker Compose installed on your system
- OCI account with access to free tier resources
- OCI configuration file with API credentials

## Setup Instructions

1. Clone this repository:
   ```bash
   git clone https://github.com/mohankumarpaluru/oracle-freetier-instance-creation.git
   cd oracle-freetier-instance-creation
   ```

2. Create a `.env` file based on the example:
   ```bash
   cp .env.example .env
   ```

3. Edit the `.env` file with your OCI configuration:
   - Set `OCI_CONFIG_CONTENT` to the entire content of your OCI config file
   - Configure other required variables (OCT_FREE_AD, DISPLAY_NAME, OCI_COMPUTE_SHAPE)
   - Set optional variables as needed

## Running the Container

1. Build and start the container:
   ```bash
   docker-compose up -d
   ```

2. Check the container logs:
   ```bash
   docker-compose logs -f
   ```

3. To stop the container:
   ```bash
   docker-compose down
   ```

## Configuration Options

### Required Environment Variables

- `OCI_CONFIG_CONTENT`: The entire content of your OCI config file
- `OCT_FREE_AD`: Availability domain (default: AD-1)
- `DISPLAY_NAME`: Name for your instance (default: OCI-Free-Instance)
- `OCI_COMPUTE_SHAPE`: Instance shape (VM.Standard.A1.Flex or VM.Standard.E2.1.Micro)

### Optional Environment Variables

- `SECOND_MICRO_INSTANCE`: Set to True to create a second micro instance (default: False)
- `REQUEST_WAIT_TIME_SECS`: Wait time between retries in seconds (default: 60)
- `OCI_SUBNET_ID`: Subnet ID (leave empty to auto-detect)
- `OCI_IMAGE_ID`: Image ID (leave empty to auto-detect)
- `OPERATING_SYSTEM`: OS for the instance (default: Canonical Ubuntu)
- `OS_VERSION`: OS version (default: 22.04)
- `ASSIGN_PUBLIC_IP`: Whether to assign a public IP (default: false)
- `BOOT_VOLUME_SIZE`: Boot volume size in GB (default: 50)

### Notification Settings

- `NOTIFY_EMAIL`: Enable email notifications (default: False)
- `EMAIL`: Your email address for notifications
- `EMAIL_PASSWORD`: Your email app password
- `DISCORD_WEBHOOK`: Discord webhook URL for notifications

## Persistent Storage

The container uses Docker volumes for persistent storage:

- `oci-config`: Stores OCI configuration
- `oci-ssh`: Stores SSH keys
- `oci-logs`: Stores log files

## Troubleshooting

### Container not starting

Check the container logs:
```bash
docker-compose logs
```

### Missing environment variables

Ensure all required environment variables are set in your `.env` file.

### OCI API errors

Check the logs for specific error messages from the OCI API:
```bash
docker exec -it oci-instance-creator cat /app/launch_instance.log
```

## License

This project is licensed under the terms of the license included in the repository.
