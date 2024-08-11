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
    software-properties-common \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Install ChromeDriver
RUN CHROME_VERSION=$(google-chrome --version | awk '{ print $3 }' | cut -d. -f1-3) \
    && CHROMEDRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION) \
    && wget -q --continue -P /chromedriver "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip" \
    && unzip /chromedriver/chromedriver* -d /usr/local/bin/ \
    && rm /chromedriver/chromedriver* \
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
COPY --from=builder /opt/google/chrome /opt/google/chrome
COPY --from=builder /usr/local/bin/chromedriver /usr/local/bin/chromedriver

# Copy JFLAP
COPY --from=builder /usr/local/bin/JFLAP7.1.jar /usr/local/bin/JFLAP7.1.jar

# Set PATH to include user-installed Python packages and Chrome
ENV PATH=/root/.local/bin:/opt/google/chrome:$PATH

# Copy application files
COPY c41lab.py negfix8 tgsconverter c4go /app/
WORKDIR /app

# Set permissions
RUN chmod 777 c41lab.py negfix8 tgsconverter c4go

# Start the application
CMD flask run -h 0.0.0.0 -p 10000 & python3 main.py
