#!/bin/bash

# Exit on any error
set -e

echo "Setting up TVTS Chatbot environment..."

# Check if Python 3+ is installed
if ! command -v python3 &> /dev/null; then
    echo "Python 3+ is required. Please install Python 3 and try again."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is required. Please install Node.js and try again."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is required. Please install Docker and try again."
    exit 1
fi

# Install frontend dependencies
echo "Installing frontend dependencies..."
cd frontend
npm install
cd ..

# Install backend dependencies
echo "Installing backend dependencies..."
cd backend
pip install -r requirements.txt
cd ..

# Start Qdrant using Docker
echo "Starting Qdrant database..."
docker run -d -p 6333:6333 qdrant/qdrant:v1.7.4

echo "Setup completed successfully!"