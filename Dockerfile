# Stage 1: Build stage
FROM bipinkrish/file-converter:latest as build-stage

# Install required dependencies
RUN apt-get update && apt-get install -y iputils-ping

# Copy the application code
COPY . /app
WORKDIR /app

# Set file permissions
RUN chmod 777 c41lab.py negfix8 tgsconverter c4go

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final stage with Ubuntu
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install required packages
RUN apt-get update && apt-get install -y python3-pip libzbar0 libmagickwand-dev python3-opencv

# Copy the installed Python packages and the app from the build stage
COPY --from=build-stage /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=build-stage /app /app

# Set the working directory
WORKDIR /app

# Set the environment variable for Flask
ENV QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"

# Run the Flask application
CMD flask run -h 0.0.0.0 -p 10000 & python3 main.py
