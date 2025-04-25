#!/bin/bash

# Exit on any error
set -e

echo "Starting TVTS Chatbot..."

# Start frontend
echo "Starting frontend..."
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

# Start backend
echo "Starting backend..."
cd backend
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4 &
BACKEND_PID=$!
cd ..

echo "Chatbot is running!"
echo "Frontend is running with PID: $FRONTEND_PID"
echo "Backend is running with PID: $BACKEND_PID"

# Trap Ctrl+C to cleanly stop the processes
trap "echo 'Stopping TVTS Chatbot...'; kill $FRONTEND_PID $BACKEND_PID; exit" INT

# Keep script running to allow processes to continue
wait