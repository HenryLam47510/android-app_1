import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CompressionService {
  static Future<Directory> _resolveTemporaryDirectory() async {
    try {
      return await getTemporaryDirectory();
    } catch (_) {
      return Directory.systemTemp;
    }
  }

  static Future<Directory> _resolveAppDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return Directory.systemTemp;
    }
  }

  static Future<String?> compressVideo(String inputPath) async {
    try {
      final Directory tempDir = await _resolveTemporaryDirectory();
      final String outputPath = p.join(
        tempDir.path,
        "compressed_${DateTime.now().millisecondsSinceEpoch}.mp4",
      );

      final String ffmpegCommand =
          "-i $inputPath -vcodec libx264 -crf 28 -preset fast $outputPath";

      print("Bắt đầu nén video: $inputPath");

      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print("Nén video thành công: $outputPath");
        return outputPath;
      } else {
        print("Lỗi nén video. Mã lỗi: $returnCode");
        return null;
      }
    } catch (e) {
      print("Exception khi nén video: $e");
      return null;
    }
  }

  static Future<String?> convertToHls(String inputPath) async {
    try {
      final Directory appDir = await _resolveAppDirectory();
      final String hlsFolder = p.join(
        appDir.path,
        "hls_${DateTime.now().millisecondsSinceEpoch}",
      );
      await Directory(hlsFolder).create(recursive: true);

      final String outputPath = p.join(hlsFolder, "index.m3u8");
      final String ffmpegCommand =
          "-i $inputPath -hls_time 10 -hls_list_size 0 -f hls $outputPath";

      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print("Cắt HLS thành công: $hlsFolder");
        return hlsFolder;
      }
      return null;
    } catch (e) {
      print("Lỗi convert HLS: $e");
      return null;
    }
  }
}
