# Build stage
FROM python:3.10-slim-buster as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    curl \
    libssl-dev \
    libmagic-dev \
    libzbar0 \
    imagemagick \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome and ChromeDriver
RUN wget -q https://storage.googleapis.com/chrome-for-testing-public/127.0.6533.99/linux64/chrome-linux64.zip \
    && unzip chrome-linux64.zip -d /opt/ \
    && rm chrome-linux64.zip \
    && wget -q https://storage.googleapis.com/chrome-for-testing-public/127.0.6533.99/linux64/chromedriver-linux64.zip \
    && unzip chromedriver-linux64.zip -d /usr/local/bin/ \
    && rm chromedriver-linux64.zip \
    && chmod +x /usr/local/bin/chromedriver

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Install additional tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    openctm-tools \
    && rm -rf /var/lib/apt/lists/*

# Download JFLAP
RUN wget https://www.jflap.org/jflaptmp/july27-18/JFLAP7.1.jar -O /usr/local/bin/JFLAP7.1.jar

# Final stage
FROM python:3.10-slim-buster

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libmagic1 \
    libzbar0 \
    imagemagick \
    iputils-ping \
    openctm-tools \
    default-jre \
    && rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder stage
COPY --from=builder /root/.local /root/.local

# Copy Chrome and ChromeDriver
COPY --from=builder /opt/chrome-linux64 /opt/chrome
COPY --from=builder /usr/local/bin/chromedriver /usr/local/bin/chromedriver

# Copy JFLAP
COPY --from=builder /usr/local/bin/JFLAP7.1.jar /usr/local/bin/JFLAP7.1.jar

# Set PATH to include user-installed Python packages and Chrome
ENV PATH=/root/.local/bin:/opt/chrome:$PATH

# Copy application files
COPY c41lab.py negfix8 tgsconverter c4go /app/
WORKDIR /app

# Set permissions
RUN chmod 777 c41lab.py negfix8 tgsconverter c4go

# Start the application
CMD flask run -h 0.0.0.0 -p 10000 & python3 main.py
