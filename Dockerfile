# Stage 1: Base image to build the application
FROM bipinkrish/file-converter:latest AS builder

# Install necessary tools and dependencies
RUN apt update && apt install -y iputils-ping

# Set the working directory
WORKDIR /app

# Copy all files to the working directory
COPY . .

# Make necessary scripts executable
RUN chmod 777 c41lab.py negfix8 tgsconverter c4go

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final image with minimal base image
FROM alpine:3.12

# Install necessary runtime dependencies
RUN apk add --no-cache python3 py3-pip

# Copy only the necessary files from the build stage
WORKDIR /app
COPY --from=builder /app .

# Set environment variable
ENV QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"

# Set executable permissions again if needed
RUN chmod 777 c41lab.py negfix8 tgsconverter c4go

# Command to run the application
CMD flask run -h 0.0.0.0 -p 10000 & python3 main.py
