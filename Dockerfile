# Use an official Python runtime as a parent image with the required version
FROM python:3.8-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies and clean up in one RUN command to reduce layer size
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsm6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# First copy only requirements to leverage Docker cache
COPY setup.py README.md /app/

# Install Python dependencies
# Note: Using onnxruntime instead of onnxruntime-gpu since Render doesn't provide GPU instances
RUN pip install --no-cache-dir -e .

# Copy the rest of the application code
COPY . /app/

# Create a non-root user and switch to it for security
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Set the entry point for Render
# You may need to modify this based on your actual application entry point
CMD ["python", "-m", "tts_arabic"]
