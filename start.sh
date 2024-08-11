#!/bin/bash
# Start Flask server in the background
flask run -h 0.0.0.0 -p 10000 &

# Run the main Python application
python3 main.py
