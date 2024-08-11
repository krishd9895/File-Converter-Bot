# Use python:3.11-slim as the base image
FROM python:3.11-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PATH=/root/.local/bin:/opt/chrome:$PATH
ENV QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libmagic1 \
    libzbar0 \
    imagemagick \
    iputils-ping \
    default-jre \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome and ChromeDriver
RUN wget -q https://storage.googleapis.com/chrome-for-testing-public/127.0.6533.99/linux64/chrome-linux64.zip \
    && unzip chrome-linux64.zip -d /opt/ \
    && rm chrome-linux64.zip \
    && wget -q https://storage.googleapis.com/chrome-for-testing-public/127.0.6533.99/linux64/chromedriver-linux64.zip \
    && unzip chromedriver-linux64.zip -d /tmp/ \
    && mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/ \
    && rm -rf /tmp/chromedriver-linux64 chromedriver-linux64.zip \
    && chmod +x /usr/local/bin/chromedriver

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Download JFLAP
RUN wget https://www.jflap.org/jflaptmp/july27-18/JFLAP7.1.jar -O /usr/local/bin/JFLAP7.1.jar

# Copy application files
COPY c41lab.py negfix8 tgsconverter c4go main.py /app/
WORKDIR /app

# Set permissions
RUN chmod 777 c41lab.py negfix8 tgsconverter c4go main.py

# Start the application
CMD ["flask", "run", "-h", "0.0.0.0", "-p", "10000"]
