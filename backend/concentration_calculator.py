"""
Module tính điểm tập trung từ dữ liệu cảm xúc
Mapping: emotion -> concentration score
"""

from typing import Dict, List


# Mapping cảm xúc → mức độ tập trung (0.0 - 1.0)
EMOTION_WEIGHTS = {
    'natural': 1.0,      # Neutral/natural face = tập trung cao
    'neutral': 1.0,
    'happy': 0.8,        # Vui = tập trung bình
    'surprised': 0.6,    # Ngạc nhiên = kém tập trung
    'sad': 0.4,          # Buồn = kém tập trung
    'fear': 0.3,         # Sợ = rất kém tập trung
    'contempt': 0.3,     # Khinh = rất kém tập trung
    'angry': 0.2,        # Tức giận = rất kém tập trung
    'disgust': 0.2,      # Ghê tởm = rất kém tập trung
    'sleepy': 0.1,       # Buồn ngủ = rất kém tập trung
    'absent': 0.0,       # Không có mặt = không tập trung
}


class ConcentrationCalculator:
    """Tính điểm tập trung từ danh sách cảm xúc"""

    def __init__(
        self,
        min_presence_threshold: float = 0.3,
        smoothing_factor: float = 0.8,
    ):
        """
        Args:
            min_presence_threshold: % tối thiểu có mặt để score có ý nghĩa
            smoothing_factor: hệ số mượt hóa (0-1)
        """
        self.min_presence_threshold = min_presence_threshold
        self.smoothing_factor = smoothing_factor

    def calculate_frame_score(self, emotion: str) -> float:
        """Lấy score từ 1 emotion"""
        return EMOTION_WEIGHTS.get(emotion.lower(), 0.0)

    def calculate_presence(self, frame_emotions: List[str]) -> float:
        """
        Tính % thời gian có mặt trước camera
        (score > 0.2 được coi là có mặt)
        """
        if not frame_emotions:
            return 0.0

        present_count = sum(1 for e in frame_emotions if self.calculate_frame_score(e) > 0.2)
        return present_count / len(frame_emotions)

    def calculate_raw_score(self, frame_emotions: List[str]) -> float:
        """Tính điểm trung bình từ tất cả frame"""
        if not frame_emotions:
            return 0.0

        total_score = sum(self.calculate_frame_score(e) for e in frame_emotions)
        return total_score / len(frame_emotions)

    def calculate_final_score(
        self,
        frame_emotions: List[str],
        use_presence: bool = True,
    ) -> Dict[str, float]:
        """
        Tính điểm tập trung cuối cùng
        
        Returns:
            {
                'raw_score': float (0-1),
                'presence': float (0-1),
                'final_score': float (0-1),
                'is_valid': bool
            }
        """
        if not frame_emotions:
            return {
                'raw_score': 0.0,
                'presence': 0.0,
                'final_score': 0.0,
                'is_valid': False,
            }

        raw_score = self.calculate_raw_score(frame_emotions)
        presence = self.calculate_presence(frame_emotions)

        # Nếu không có mặt đủ, score = 0
        if presence < self.min_presence_threshold:
            is_valid = False
            final_score = 0.0
        else:
            is_valid = True
            # Kết hợp raw_score (70%) + presence (30%)
            final_score = (raw_score * 0.7 + presence * 0.3)

        final_score = max(0.0, min(1.0, final_score))

        return {
            'raw_score': round(raw_score, 3),
            'presence': round(presence, 3),
            'final_score': round(final_score, 3),
            'is_valid': is_valid,
        }

    def get_focus_status(self, final_score: float) -> str:
        """Lấy trạng thái text từ score"""
        if final_score >= 0.7:
            return "Tập trung tốt"
        elif final_score >= 0.5:
            return "Tập trung bình"
        elif final_score >= 0.3:
            return "Cần chú ý"
        else:
            return "Rất kém tập trung"

    def get_focus_emoji(self, final_score: float) -> str:
        """Lấy emoji từ score"""
        if final_score >= 0.7:
            return "🔥"
        elif final_score >= 0.5:
            return "⚡"
        elif final_score >= 0.3:
            return "⚠️"
        else:
            return "😴"

    def analyze(
        self,
        frame_emotions: List[str],
        emotion_breakdown: Dict[str, float],
    ) -> Dict:
        """
        Phân tích hoàn chỉnh
        
        Returns:
            {
                'concentration_score': float,
                'focus_status': str,
                'focus_emoji': str,
                'presence': float,
                'raw_score': float,
                'emotion_breakdown': dict,
                'frame_count': int,
            }
        """
        scores = self.calculate_final_score(frame_emotions)

        return {
            'concentration_score': scores['final_score'],
            'focus_status': self.get_focus_status(scores['final_score']),
            'focus_emoji': self.get_focus_emoji(scores['final_score']),
            'raw_score': scores['raw_score'],
            'presence': scores['presence'],
            'is_valid': scores['is_valid'],
            'emotion_breakdown': emotion_breakdown,
            'frame_count': len(frame_emotions),
        }
