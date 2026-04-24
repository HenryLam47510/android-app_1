import cv2
import numpy as np
from typing import List, Dict, Tuple
import tempfile
import os


class VideoProcessor:
    """Xử lý video: extract frames, phát hiện emotions"""

    def __init__(self, video_path: str, target_fps: int = 1):
        """
        Args:
            video_path: đường dẫn file video
            target_fps: số frame lấy mỗi giây (default=1)
        """
        self.video_path = video_path
        self.target_fps = target_fps
        self.frames = []
        self.frame_emotions = []

    def extract_frames(self) -> List[np.ndarray]:
        """Lấy frame từ video với tốc độ target_fps"""
        try:
            cap = cv2.VideoCapture(self.video_path)

            if not cap.isOpened():
                raise ValueError(f"Không thể mở file video: {self.video_path}")

            # Lấy FPS của video
            source_fps = cap.get(cv2.CAP_PROP_FPS)
            total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

            # Tính frame skip (lấy cách bao nhiêu frame)
            frame_skip = max(1, int(source_fps / self.target_fps))

            frame_count = 0
            frame_num = 0

            while True:
                ret, frame = cap.read()

                if not ret:
                    break

                # Lấy frame nếu thỏa điều kiện
                if frame_num % frame_skip == 0:
                    # Resize cho tốc độ inference nhanh hơn
                    resized = cv2.resize(frame, (640, 480))
                    self.frames.append(resized)
                    frame_count += 1

                frame_num += 1

            cap.release()
            return self.frames

        except Exception as e:
            raise Exception(f"Lỗi extract frames: {str(e)}")

    def detect_emotions(self, model, confidence_threshold: float = 0.5) -> Dict:
        """
        Phát hiện emotions trên tất cả frames
        
        Args:
            model: YOLOv5 model
            confidence_threshold: ngưỡng confidence tối thiểu
            
        Returns:
            {
                'frame_emotions': [emotion1, emotion2, ...],
                'emotion_counts': {emotion: count},
                'emotion_confidences': {emotion: [conf1, conf2, ...]},
                'total_detections': int,
            }
        """
        emotion_counts = {}
        emotion_confidences = {}
        total_detections = 0

        for frame in self.frames:
            try:
                # Run YOLO inference
                results = model(frame)
                if isinstance(results, list):
                    result = results[0]
                else:
                    result = results

                boxes = result.boxes

                if boxes is not None and len(boxes) > 0:
                    # Lấy detection có confidence cao nhất (giả sử 1 emotion/frame)
                    best_idx = boxes.conf.argmax()
                    cls_id = int(boxes.cls[best_idx])
                    confidence = float(boxes.conf[best_idx])
                    emotion = result.names[cls_id]

                    if confidence >= confidence_threshold:
                        self.frame_emotions.append(emotion)

                        # Đếm emotions
                        emotion_counts[emotion] = emotion_counts.get(emotion, 0) + 1

                        # Lưu confidences
                        if emotion not in emotion_confidences:
                            emotion_confidences[emotion] = []
                        emotion_confidences[emotion].append(confidence)

                        total_detections += 1
                else:
                    # Không detect được emotion
                    self.frame_emotions.append('neutral')

            except Exception as e:
                print(f"Lỗi phát hiện emotion: {str(e)}")
                self.frame_emotions.append('error')

        return {
            'frame_emotions': self.frame_emotions,
            'emotion_counts': emotion_counts,
            'emotion_confidences': emotion_confidences,
            'total_detections': total_detections,
            'total_frames': len(self.frames),
        }

    def calculate_emotion_percentages(
        self, emotion_counts: Dict[str, int]
    ) -> Dict[str, float]:
        """Tính phần trăm từng cảm xúc"""
        total = sum(emotion_counts.values())
        if total == 0:
            return {}

        return {
            emotion: (count / total) * 100
            for emotion, count in emotion_counts.items()
        }

    def get_dominant_emotion(self, emotion_counts: Dict[str, int]) -> str:
        """Lấy cảm xúc chính (xuất hiện nhiều nhất)"""
        if not emotion_counts:
            return 'neutral'
        return max(emotion_counts, key=emotion_counts.get)

    def process(self, model) -> Dict:
        """
        Xử lý video hoàn chỉnh
        
        Returns:
            {
                'frame_emotions': list,
                'emotion_breakdown': dict percentage,
                'dominant_emotion': str,
                'total_frames': int,
            }
        """
        # Extract frames
        frames = self.extract_frames()

        # Detect emotions
        detection_result = self.detect_emotions(model)

        # Calculate percentages
        emotion_percentages = self.calculate_emotion_percentages(
            detection_result['emotion_counts']
        )

        # Get dominant emotion
        dominant = self.get_dominant_emotion(detection_result['emotion_counts'])

        return {
            'frame_emotions': detection_result['frame_emotions'],
            'emotion_breakdown': emotion_percentages,
            'dominant_emotion': dominant,
            'total_frames': detection_result['total_frames'],
            'detected_frames': detection_result['total_detections'],
            'emotion_counts': detection_result['emotion_counts'],
        }
