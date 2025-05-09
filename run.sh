#!/bin/bash

echo "Đang khởi động Chatbot TVTS..."

frontend_npm_pid=""
backend_py_pid=""

handle_interrupt() {
echo
echo "Tập lệnh bị gián đoạn. Đang thoát tập lệnh..."
echo "Các quá trình frontend và backend có thể vẫn đang chạy trong nền."
echo "Để dừng chúng, bạn có thể sử dụng 'kill <PID>' hoặc pkill."
echo "PID Frontend là: $frontend_npm_pid"
echo "PID Backend là: $backend_py_pid"
exit 0
}

trap handle_interrupt SIGINT

echo "Đang khởi động frontend..."
cd frontend || { echo "LỖI: Không thể cd đến frontend. Đang hủy bỏ."; exit 1; }
npm run dev &
frontend_npm_pid=$!
cd ..
echo "Frontend (npm run dev) đã được khởi động với PID $frontend_npm_pid"

echo "Đang khởi động backend..."
cd backend || { echo "LỖI: Không thể cd đến backend. Đang hủy bỏ."; exit 1; }
python -m app.main &
backend_py_pid=$!
cd ..
echo "Backend (python -m app.main) đã được khởi động với PID $backend_py_pid"

echo
echo "Chatbot đang chạy!"
echo "Frontend (npm PID: $frontend_npm_pid)"
echo "Backend (Python PID: $backend_py_pid)"
echo
echo "Nhấn Ctrl+C để thoát tập lệnh này."
echo "Các quá trình frontend và backend sẽ tiếp tục chạy trong nền."
echo "Bạn sẽ cần phải dừng chúng thủ công."

tail -f /dev/null