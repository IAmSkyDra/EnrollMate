# TVTS Chatbot

## Giới thiệu
Chatbot này là một giải pháp toàn diện dành cho các trường đại học tại Việt Nam, nhằm nâng cao hiệu quả tư vấn tuyển sinh hiện có và mở rộng quy mô tiếp cận. Chatbot có khả năng trả lời các câu hỏi thường gặp, tìm kiếm thông tin liên quan trong các tài liệu do trường cung cấp, và phản hồi như một trợ lý chuyên nghiệp đối với các câu hỏi không liên quan đến tuyển sinh.

Cách hoạt động của chatbot bắt đầu bằng việc tra cứu cơ sở dữ liệu các câu hỏi thường gặp do trường đại học cung cấp dựa trên câu hỏi của học sinh. Nếu tìm được câu hỏi phù hợp, chatbot sẽ trả lời ngay lập tức, có thể được diễn đạt lại tùy theo yêu cầu của trường. Nếu không tìm thấy câu hỏi phù hợp, hệ thống sẽ sử dụng mô hình RAG để truy xuất thông tin phù hợp nhất từ các tài liệu được cung cấp. Nếu vẫn không tìm thấy thông tin, chatbot sẽ sử dụng mô hình ngôn ngữ lớn (LLM) để đưa ra câu trả lời.

## Cấu trúc thư mục
Gồm 2 phần chính, frontend và backend.

Thư mục frontend chứa code giao diện để người dùng tương tác với chatbot.

Thư mục backend chứa code truy vấn FAQ, RAG và kết nối với LLM để trả lời các câu hỏi.
## Cài đặt môi trường
Để chạy được dự án, cần:
- Python 3+
- Nodejs
- Docker
### Cài đặt qdrant bằng Docker
Chạy lệnh sau để thiết lập cơ sở dữ liệu qdrant phục vụ cho truy vấn:
```
docker run -d -p 6333:6333 qdrant/qdrant:v1.7.4
```
### Cài đặt Mongodb bằng Docker 
Chạy lệnh sau để thiết lập cơ sở dữ liệu Mongodb để lưu lịch sử trò chuyện:
```
docker run -d --name mongodb -p 27017:27017 mongo:latest
```
## Hướng dẫn thiết lập nhanh
- Chạy file setup.sh đối với Linux hoặc setup.bat đối với Windows để cài đặt các gói cần thiết.
- Chạy file run.sh đối với Linux hoặc run.bat đối với Windows để khởi động ứng dụng.
## Hướng dẫn thiết lập từng bước
### Frontend
Trước tiên, cài các gói cần thiết với `npm`
```
npm install
```
Sau đó, chạy
```
npm run dev
```
để khởi động giao diện chatbot.
### Backend
Trước tiên, cài các gói cần thiết với `pip`
```
pip install -r requirements.txt
```

#### Chế độ phát triển
```
python main.py --dev
```

#### Chế độ vận hành
- **Bước 1:** Khởi động TGI
```
text-generation-launcher \
    --model-id ura-hcmut/ura-llama-2.1-8b \
    --port 10025 \
    --watermark-gamma 0.25 \
    --watermark-delta 2 \
    --max-input-tokens 4096 \
    --max-total-tokens 8192 \
    --max-batch-prefill-tokens 8242 \
    --trust-remote-code \
    --cuda-memory-fraction 0.8
```
- **Bước 2:** Khởi động backend
```
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

hoặc
```
python main.py
```
## Hướng dẫn nạp dữ liệu
### Chuẩn bị FAQ
Chúng tôi đã chuẩn bị sẵn 01 file dữ liệu mẫu FAQ ở thư mục `backend/data` mang tên `hcmut_data_faq.csv`.
File gồm 2 cột:
- `query` - chứa các câu hỏi
- `answer` - chứa các câu trả lời tương ứng với các câu hỏi.
### Chuẩn bị các tài liệu cho RAG
Chúng tôi đã chuẩn bị sẵn 01 file dữ liệu mẫu cho RAG ở thư mục `backend/data` mang tên `hcmut_data_web.json`.
Dữ liệu gồm các trường:
- url: link đến trang web chứa thông tin
- text: dữ liệu văn bản để RAG có thể truy vấn
- images: các đường dẫn đến các ảnh có trong tài liệu
- tables: các bảng trong tài liệu được lưu dưới dạng markdown
- attachments: các tệp đính kèm khác
### Nạp dữ liệu
Tiến hành chạy lệnh sau để nạp dữ liệu sẵn sàng cho Chatbot.
```
python main.py --reindex
```

## Cấu hình
### Cấu hình frontend
Chỉnh sửa file `.env.local` để cấu hình:
- Chỉnh sửa thông tin kết nối database
```
MONGODB_DB_NAME=chat_ui
MONGODB_URL=mongodb://localhost:27017/mydb
```
- Chỉnh sửa thông tin kết nối với server backend:
```
      "endpoints": [{
        "type" : "tgi",
        "url": "http://127.0.0.1:8000/generate_stream"
      }]
```
- Chỉnh sửa tên trường đại học/sản phẩm:
```
PUBLIC_APP_NAME=HCMUT Chatbot # name used as title throughout the app
```
### Cấu hình backend
Chỉnh sửa file `envs.py` để cấu hình:

- Chỉnh sửa link kết nối database Qdrant:
``` 
QDRANTDB_URL = "http://localhost:6333"
```
- Chỉnh sửa mô hình embedding tiếng Việt:
```
EMBEDDING_MODEL = "bkai-foundation-models/vietnamese-bi-encoder"
```
- Chỉnh sửa địa chỉ TGI chạy mô hình ngôn ngữ lớn:
```
TGI_URL = "http://localhost:10025"
```

