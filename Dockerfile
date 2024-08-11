# Build stage
FROM bipinkrish/file-converter:latest as build-stage

# Install any additional dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    iputils-ping \
    build-essential \
    python3-opencv

# Copy the application files and set permissions
COPY . /app
WORKDIR /app
RUN chmod 777 c41lab.py negfix8 tgsconverter c4go

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Final stage
FROM alpine:3.18

# Install necessary runtime dependencies
RUN apk --no-cache add python3 py3-pip bash libmagic zbar imagemagick

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Copy the installed Python packages and the app from the build stage
COPY --from=build-stage /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# Copy the application files
COPY --from=build-stage /app /app

# Set environment variables
ENV QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"

# Start the application
CMD flask run -h 0.0.0.0 -p 10000 & python3 main.py
