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
Do trên backend, các bản ghi FAQ được lưu trên cơ sở dữ liệu vector Qdrant nên chúng ta cần phải cài đặt.
Chạy lệnh sau để thiết lập cơ sở dữ liệu qdrant phục vụ cho truy vấn:
```
docker run -d -p 6333:6333 qdrant/qdrant:v1.7.4
```


### Cài đặt Mongodb bằng Docker 
Do trên frontend, lịch sử cuộc trò chuyện được lưu bằng MongoDB, nên chúng ta cũng cần tải.
Chạy lệnh sau để thiết lập cơ sở dữ liệu Mongodb để lưu lịch sử trò chuyện:
```
docker run -d --name mongodb -p 27017:27017 mongo:latest
```

## Cài đặt các gói
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



#### Tạo và Kích hoạt Môi trường ảo

Rất khuyến khích sử dụng môi trường ảo để quản lý các gói phụ thuộc (dependencies) của dự án.

**Linux/macOS:**
```bash
python3 -m venv venv
source venv/bin/activate
```

**Windows:**
```bash
python -m venv venv
.\venv\Scripts\activate
```

#### Cài đặt các gói phụ thuộc

```bash
pip install -r requirements.txt
```

#### Cấu hình Biến Môi trường

Sao chép tệp môi trường mẫu và cập nhật nó với các cấu hình cụ thể của bạn:

```bash
cp .env.example .env
```
(Sau đó, mở tệp `.env` vừa tạo và chỉnh sửa các giá trị cho phù hợp với thiết lập của bạn.)
## Cấu hình Dữ liệu FAQ và RAG 


### 1. Chuẩn bị Dữ liệu

**a. Dữ liệu FAQ:**

Dữ liệu FAQ dùng để trả lời trực tiếp các câu hỏi phổ biến.

*   **Định dạng tệp:**
    *   **CSV (`.csv`):** Tệp phải có hai cột là `query` (câu hỏi) và `answer` (câu trả lời).
        ```csv
        query,answer
        "Yêu cầu tuyển sinh là gì?","Yêu cầu tuyển sinh bao gồm bằng tốt nghiệp THPT và điểm thi chuẩn hóa."
        "Học phí bao nhiêu?","Học phí thay đổi theo từng chương trình. Vui lòng kiểm tra website trường."
        ```
    *   **JSON (`.json`):** Một mảng các đối tượng, mỗi đối tượng có khóa `query` và `answer`.
        ```json
        [
          {
            "query": "Yêu cầu tuyển sinh là gì?",
            "answer": "Yêu cầu tuyển sinh bao gồm bằng điểm thi tốt nghiệp THPTQG."
          },
          {
            "query": "Học phí bao nhiêu?",
            "answer": "Học phí thay đổi theo từng chương trình. Vui lòng kiểm tra website trường."
          }
        ]
        ```
*   **Vị trí tệp:** Bạn nên đặt các tệp dữ liệu này trong thư mục `data/` của dự án (ví dụ: `data/hcmut_data_faq.csv`).

**b. Dữ liệu Web (cho RAG):**

Dữ liệu web được sử dụng để chatbot tìm kiếm thông tin chi tiết từ các nguồn tài liệu dạng văn bản (ví dụ: nội dung trang web đã được cào).

*   **Định dạng tệp:**
    *   **JSON (`.json`):** Một mảng các đối tượng, mỗi đối tượng có các khóa:
        *   `text`: Nội dung văn bản chính của tài liệu/trang.
        *   `tables`: Một mảng các chuỗi, mỗi chuỗi là một bảng đã được serialize dưới dạng văn bản (ví dụ: Markdown, HTML).
        ```json
        [
          {
            "text": "Đây là nội dung chính của trang 1. Trang này thảo luận về các chương trình học thuật.",
            "tables": [
              "| Chương trình | Thời gian | Tín chỉ |\n|---|---|---|\n| CS | 4 năm | 120 |",
              "| EE | 4 năm | 124 |"
            ]
          },
          {
            "text": "Trang 2 nói về đời sống sinh viên và cơ sở vật chất.",
            "tables": []
          }
        ]
        ```
    *   **CSV (`.csv`):** Tệp phải có cột `text` và `tables`. Cột `tables` nên là một chuỗi biểu diễn một danh sách các chuỗi bảng (ví dụ: một chuỗi JSON của một danh sách).
        ```csv
        text,tables
        "Đây là nội dung chính của trang 1. Trang này thảo luận về các chương trình học thuật.","[\"| Chương trình | Thời gian | Tín chỉ |\\n|---|---|---|\\n| CS | 4 năm | 120 |\", \"| EE | 4 năm | 124 |\"]"
        "Trang 2 nói về đời sống sinh viên và cơ sở vật chất.","[]"
        ```
        *Lưu ý: Lưu trữ các cấu trúc phức tạp như danh sách bảng trong CSV có thể không tiện lợi. JSON thường được ưu tiên cho dữ liệu web.*
*   **Vị trí tệp:** Tương tự như FAQ, bạn nên đặt tệp dữ liệu web trong thư mục `data/` (ví dụ: `data/hcmut_data_web.json`).


### 2. Nạp Dữ liệu (Reindexing)

Sau khi đã chuẩn bị các tệp dữ liệu, bạn cần chạy quá trình "reindexing" để xử lý, tạo vector embeddings và lưu trữ chúng vào Qdrant.

Thực hiện lệnh sau trong terminal (đảm bảo bạn đã kích hoạt môi trường ảo của dự án):

```bash
python -m app.main --reindex
```

Hệ thống sẽ yêu cầu bạn nhập đường dẫn đến các tệp dữ liệu:

```
Starting reindexing process...
Enter the path to the FAQ file (e.g., data/faq.csv): data/hcmut_data_faq.csv
Enter the path to the Web data file (e.g., data/web.json): data/hcmut_data_web.json
... (log xử lý) ...
Database reindexing completed successfully.
```

*   **Đường dẫn tệp:** Cung cấp đường dẫn tương đối (ví dụ: `data/ten_file.csv`) hoặc đường dẫn tuyệt đối đến các tệp dữ liệu của bạn.
*   **Chế độ phát triển (`--dev`):** Nếu bạn muốn thử nghiệm với một tập dữ liệu nhỏ hơn để quá trình reindex diễn ra nhanh hơn, sử dụng cờ `--dev`:
    ```bash
    python -m app.main --reindex --dev
    ```
*   **Reindexing với Docker Compose:** Nếu bạn đang chạy ứng dụng bằng Docker Compose, bạn có thể thực thi lệnh reindex bên trong container `app` đang chạy:
    ```bash
    docker-compose exec app python -m app.main --reindex
    ```
    Lưu ý rằng đường dẫn tệp bạn nhập phải là đường dẫn có thể truy cập được từ *bên trong hệ thống tệp của container*. Nếu thư mục `data/` của bạn được mount vào container (như cấu hình trong `docker-compose.yml` mẫu), bạn có thể sử dụng các đường dẫn như `data/hcmut_data_faq.csv`.

## Cấu hình chạy
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
Chỉnh sửa file `.env` để cấu hình:

- Chỉnh sửa link kết nối database Qdrant:
``` 
QDRANTDB_URL = "http://localhost:6333"
```
### Cấu hình Text Embedding

Phần này mô tả cách thiết lập máy chủ nếu bạn chọn sử dụng Hugging Face với loại API là `text_embeddings_inference` để tạo nhúng.

Biến môi trường `EMBEDDING_PROVIDER` xác định nhà cung cấp dịch vụ nhúng. Nó có thể nhận các giá trị như `"openai"`, `"huggingface"`, hoặc `"sentence_transformers"`. Dưới đây là hướng dẫn cho từng trường hợp:

---

#### Trường hợp 1: `EMBEDDING_PROVIDER="huggingface"` (và `EMBEDDING_HUGGINGFACE_API_TYPE="text_embeddings_inference"`)

Nếu bạn chọn `EMBEDDING_PROVIDER="huggingface"` và `EMBEDDING_HUGGINGFACE_API_TYPE="text_embeddings_inference"`, bạn cần chạy một máy chủ TEI. Điều này cho phép bạn tự host (tự triển khai và vận hành) các mô hình nhúng (embedding models) mã nguồn mở.

**Ví dụ sử dụng Docker cho `bkai-foundation-models/vietnamese-bi-encoder` (CPU):**

```bash
docker run -p 8080:80 \
    --pull always \
    ghcr.io/huggingface/text-embeddings-inference:cpu-latest \
    --model-id bkai-foundation-models/vietnamese-bi-encoder
```

**Để hỗ trợ GPU (yêu cầu driver NVIDIA và NVIDIA Container Toolkit):**

```bash
docker run -p 8080:80 --gpus all \
    --pull always \
    ghcr.io/huggingface/text-embeddings-inference:latest \
    --model-id bkai-foundation-models/vietnamese-bi-encoder
```

*   Máy chủ TEI sẽ có thể truy cập tại `http://localhost:8080`.
*   Cập nhật `EMBEDDING_HUGGINGFACE_BASE_URL="http://localhost:8080"` trong tệp `.env` của bạn.
*   `SentenceTransformersDocumentEmbedder` trong Haystack sau đó có thể sử dụng máy chủ TEI này bằng cách cấu hình `api_type` của nó thành `text_embeddings_inference` và cung cấp `api_key` (nếu máy chủ TEI của bạn được bảo mật, mặc dù lệnh Docker mặc định không thiết lập khóa API) và `url`. Tệp [`app/utils/embedders.py`](app/utils/embedders.py:1) của ứng dụng chúng ta xử lý cấu hình này dựa trên các biến môi trường.

Bạn có thể thay thế `bkai-foundation-models/vietnamese-bi-encoder` bằng bất kỳ mô hình Sentence Transformer nào khác tương thích với TEI. Xem [tài liệu Text Embeddings Inference](https://huggingface.co/docs/text-embeddings-inference/index) để biết thêm các mô hình và cấu hình nâng cao.

---

#### Trường hợp 2: `EMBEDDING_PROVIDER="openai"`

Nếu bạn chọn `EMBEDDING_PROVIDER="openai"`, ứng dụng sẽ sử dụng API của OpenAI để tạo nhúng.

*   **Không cần thiết lập bất kỳ máy chủ mới nào.**
*   Bạn chỉ cần đảm bảo rằng các biến môi trường liên quan đến OpenAI (như khóa API) đã được cấu hình chính xác trong tệp `.env` của bạn.

---

#### Trường hợp 3: `EMBEDDING_PROVIDER="sentence_transformers"` (sử dụng trực tiếp, không qua TEI)

Nếu bạn chọn `EMBEDDING_PROVIDER="sentence_transformers"` (và `EMBEDDING_HUGGINGFACE_API_TYPE` không được đặt thành `"text_embeddings_inference"` hoặc không liên quan), thư viện Sentence Transformers sẽ được sử dụng trực tiếp để tải và chạy các mô hình nhúng trong tiến trình của ứng dụng.

*   **Không cần thiết lập bất kỳ máy chủ mới nào.**
*   Mô hình sẽ được tải xuống và chạy cục bộ bởi ứng dụng. Đảm bảo bạn có đủ tài nguyên (CPU/RAM) và kết nối internet để tải mô hình lần đầu.

---
### Cấu hình mô hình ngôn ngữ lớn
#### Cách 1: Sử dụng API OpenAI (hoặc Claude, Gemini và bất kỳ model nào hỗ trợ giao thức giống OpenAI)

Nếu bạn muốn sử dụng các mô hình của OpenAI (ví dụ: GPT-3.5, GPT-4):

1.  **Lấy API Key của OpenAI:** Bạn cần có một API key từ OpenAI.
2.  **Cấu hình biến môi trường:** Mở file `.env` và thiết lập các biến sau:
    *   `OPENAI_API_KEY`: Đặt giá trị này thành API key của bạn.
        ```env
        OPENAI_API_KEY="sk-your_openai_api_key_here"
        ```
    *   `LLM_MODEL_ID`: Chỉ định model OpenAI bạn muốn sử dụng.
        ```env
        LLM_MODEL_ID="gpt-3.5-turbo" # Hoặc "gpt-4", "text-davinci-003", v.v.
        ```
    *   `LLM_OPENAI_BASE_URL`: Nếu bạn sử dụng API chính thức của OpenAI, bạn có thể để trống biến này hoặc đặt thành `https://api.openai.com/v1`. Nếu bạn sử dụng một proxy hoặc dịch vụ tương thích OpenAI khác, hãy đặt URL tương ứng.
        ```env
        LLM_OPENAI_BASE_URL="https://api.openai.com/v1" # (Mặc định nếu để trống và dùng OpenAI)
        ```
Các bước thiết lập cũng tương tự cho Claude, Gemini,... vì chúng đều tương thích với giao thức của OpenAI.
#### Cách 2: Sử dụng Máy chủ Text Generation Inference (TGI) Tự Host

Nếu bạn muốn tự host một mô hình LLM mã nguồn mở bằng Text Generation Inference (TGI) của Hugging Face:

1.  **Thiết lập và Chạy TGI Server:**
    *   Làm theo hướng dẫn chi tiết tại mục "[7. Set Up Hugging Face Text Generation Inference (TGI) Server](#7-set-up-hugging-face-text-generation-inference-tgi-server)".
    *   Khi chạy TGI server (bằng Docker hoặc cách khác), hãy đảm bảo bạn chỉ định `--model-id` là model bạn muốn sử dụng (ví dụ: `gpt2`, `mistralai/Mistral-7B-Instruct-v0.1`, hoặc một model tương thích TGI khác).
        ```bash
        # Ví dụ chạy TGI với model gpt2 trên CPU
        docker run -p 8081:80 --pull always \
            -v $(pwd)/tgi_cache:/data \
            ghcr.io/huggingface/text-generation-inference:latest \
            --model-id gpt2 --port 80
        ```
    *   Nếu bạn sử dụng `docker-compose.yml` được cung cấp, dịch vụ `tgi_server` sẽ sử dụng biến `LLM_MODEL_ID` từ file `.env` của bạn để tải model cho TGI. Hãy đảm bảo `LLM_MODEL_ID` trong `.env` là model bạn muốn TGI phục vụ.

2.  **Cấu hình Ứng dụng FastAPI để Kết nối Tới TGI Server:**
    *   Mở file `.env` và cập nhật các biến sau:
        *   `LLM_OPENAI_BASE_URL`: Đặt thành URL của TGI server của bạn, thường là với đường dẫn `/v1` để tương thích với API của OpenAI.
            *   Nếu TGI server chạy cục bộ trên port `8081` (như ví dụ Docker ở trên):
                ```env
                LLM_OPENAI_BASE_URL="http://localhost:8081/v1"
                ```
            *   Nếu bạn sử dụng `docker-compose.yml` và dịch vụ TGI có tên là `tgi_server` và lắng nghe trên port `80` bên trong mạng Docker:
                ```env
                LLM_OPENAI_BASE_URL="http://tgi_server:80/v1"
                ```
        *   `LLM_MODEL_ID`: (Tùy chọn cho ứng dụng, chủ yếu để tham khảo khi không dùng docker-compose cho TGI) Đặt thành model ID bạn đang phục vụ với TGI. Model thực tế được phục vụ do lệnh khởi chạy TGI hoặc cấu hình `docker-compose.yml` cho TGI quyết định.
            ```env
            LLM_MODEL_ID="your-model-id" # Ví dụ: gpt2, mistralai/Mistral-7B-Instruct-v0.1
            ```
        *   `OPENAI_API_KEY`: Đối với TGI tự host không có bảo vệ bằng API key (như các lệnh Docker ví dụ), bạn có thể **để trống** biến này hoặc đặt một giá trị giả bất kỳ (ví dụ: `dummy_key` hoặc `not_needed`). Một số thư viện phía client (như thư viện OpenAI Python) có thể yêu cầu biến này phải được đặt, ngay cả khi server không sử dụng nó.
            ```env
            OPENAI_API_KEY="" # Hoặc "dummy_key"
            ```
Chúng tôi đặc biệt đề xuất các mô hình được phát triển bởi **The Unlimited Research Group of Artificial Intelligence (URA)**. URA là nhóm nghiên cứu trực thuộc Khoa Khoa học và Kỹ thuật Máy tính, Trường Đại học Bách Khoa (Đại học Quốc gia TP.HCM), do PGS. TS. Quân Quang Thọ dẫn dắt. Tên gọi URA còn mang ý nghĩa "yoU aRe Advengers", khuyến khích mỗi thành viên phát huy cá tính riêng, đồng thời cùng nhau tập trung vào sứ mệnh của nhóm là thúc đẩy sự phát triển của lĩnh vực khoa học máy tính nói chung và trí tuệ nhân tạo nói riêng.

Các mô hình từ URA như:
*   **MixSUra**: Dòng mô hình Ngôn ngữ Lớn Mixture-of-Experts (MoE) tiên tiến cho tiếng Việt (ví dụ: `ura-hcmut/MixSUra`, `ura-hcmut/MixSUra-SFT`).
*   **GemSUra**: Dòng mô hình Ngôn ngữ Lớn được huấn luyện trước dựa trên Gemma, xây dựng bởi URA (ví dụ: `ura-hcmut/GemSUra-7B`, `ura-hcmut/GemSUra-2B`).
*   **URA-LLaMa**: Dòng mô hình LLaMa-2 được huấn luyện trước đầu tiên cho tiếng Việt (ví dụ: `ura-hcmut/ura-llama-2.1-8b`, `ura-hcmut/ura-llama-2-8b`, `ura-hcmut/ura-llama-7b`, `ura-hcmut/ura-llama-13b`).

Những mô hình này được huấn luyện trên các tập dữ liệu tiếng Việt lớn, nhờ đó có khả năng hiểu và xử lý tiếng Việt rất tốt. Chúng là lựa chọn tuyệt vời để triển khai với TGI server cho các ứng dụng chatbot hoặc các tác vụ xử lý ngôn ngữ tự nhiên tiếng Việt khác.

Khi chọn model ID cho TGI server, bạn có thể sử dụng một trong các model ID trên từ Hugging Face Hub của URA. Ví dụ:
```bash
# Ví dụ chạy TGI với model URA-LLaMa trên GPU
docker run -p 8081:80 --gpus all --pull always \
    -v $(pwd)/tgi_cache:/data \
    ghcr.io/huggingface/text-generation-inference:latest \
    --model-id ura-hcmut/ura-llama-2.1-8b --port 80
```
**Lưu ý quan trọng khi dùng TGI:**
*   Đảm bảo model bạn chọn tương thích với phiên bản TGI bạn đang sử dụng.
*   TGI có thể yêu cầu tài nguyên phần cứng đáng kể (đặc biệt là VRAM GPU) cho các model lớn. 


## Chạy ứng dụng
Sau khi hoàn tất thiết lập, bạn có thể chạy ứng dụng FastAPI (backend):

```bash
python -m app.main
```

và ChatUI ở frontend:
```
npm run dev
```
API sẽ có thể truy cập tại `http://<APP_HOST>:<APP_PORT>` (ví dụ: `http://localhost:8000` theo mặc định).
Bạn có thể truy cập tài liệu OpenAPI tại `http://localhost:8000/docs`.

Hoặc có thể Chạy file run.sh đối với Linux hoặc run.bat đối với Windows để khởi động ứng dụng.