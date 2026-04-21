import uvicorn
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import torch
from PIL import Image
import io
import numpy as np

app = FastAPI()

# Cho phép tất cả các nguồn truy cập (Web/Mobile/Desktop)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model (Sử dụng YOLOv5/v8 hoặc PyTorch tùy vào cách bạn train)
# Lưu ý: Bạn cần cài đặt thư viện ultralytics hoặc torch
model = torch.hub.load('ultralytics/yolov5', 'custom', path='../app/src/main/assets/best.pt')

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    # Đọc ảnh từ request
    request_object_content = await file.read()
    img = Image.open(io.BytesIO(request_object_content))

    # Thực hiện nhận diện
    results = model(img)

    # Giả sử model trả về các class cảm xúc, ta tính toán độ tập trung
    # Ở đây tôi ví dụ logic: lấy cảm xúc có độ tin tưởng cao nhất
    detections = results.pandas().xyxy[0]

    if not detections.empty:
        # Lấy nhãn đầu tiên (ví dụ: 'focus', 'distracted')
        label = detections.iloc[0]['name']
        confidence = float(detections.iloc[0]['confidence'])

        # Logic tính % tập trung demo
        focus_score = confidence if label == 'focus' else (1 - confidence)
        return {"focus_level": round(focus_score, 2), "label": label}

    return {"focus_level": 0.5, "label": "neutral"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
