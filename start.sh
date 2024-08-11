#!/bin/bash
# Set Flask environment variable
export FLASK_APP=/app/app.py

# Start Flask server
flask run -h 0.0.0.0 -p 10000
