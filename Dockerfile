FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install ssh-keygen (part of openssh-client)
RUN apt-get update && apt-get install -y openssh-client && rm -rf /var/lib/apt/lists/*


# Copy application files
COPY main.py .
COPY setup_init.sh .
COPY email_content.html .

# Create directories for persistent data
RUN mkdir -p /app/config /app/ssh /app/logs

# Copy entrypoint script
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
