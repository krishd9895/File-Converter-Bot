# Stage 1: Build stage
FROM bipinkrish/file-converter:latest AS build-stage

RUN apt-get update && apt-get install -y --no-install-recommends \
    iputils-ping \
    build-essential \
    zbar-tools \
    libzbar-dev \
    libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . /app
WORKDIR /app

RUN chmod 777 c41lab.py negfix8 tgsconverter c4go

RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final stage with Ubuntu
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y python3-pip libzbar0 libmagickwand-dev

# Install OpenCV and other Python dependencies
RUN apt-get update && apt-get install -y python3-opencv

WORKDIR /app

# Copy necessary files from the build stage
COPY --from=build-stage /app /app

# Install runtime dependencies including OpenCV
RUN pip install --no-cache-dir pyrogram tgcrypto pickle5==0.0.11 telegraph pykeyboard==0.1.5 halo==0.0.31 Wand==0.6.8 tensorflow-cpu==2.9.1 requests SpeechRecognition pydub gTTS Pillow bs4 ttconv py2many pyzbar pyinstaller asteval arrow plotly kaleido websocket-client flask python-dotenv

ENV QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"

CMD flask run -h 0.0.0.0 -p 10000 & python3 main.py
