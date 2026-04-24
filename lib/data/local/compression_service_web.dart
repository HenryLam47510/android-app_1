class CompressionService {
  static Future<String?> compressVideo(String inputPath) async {
    // Trên Web, không nén video cục bộ.
    return inputPath;
  }

  static Future<String?> convertToHls(String inputPath) async {
    // Không hỗ trợ chuyển đổi HLS trên Web.
    return null;
  }
}
