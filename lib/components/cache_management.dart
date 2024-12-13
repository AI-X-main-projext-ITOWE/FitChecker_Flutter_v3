import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class CacheManager {

  // 캐시 디렉토리 크기 계산
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await getTemporaryDirectory(); // 임시 디렉토리 가져오기
      print("Cache Directory Path: ${cacheDir.path}"); // 디렉토리 경로 출력
      final files = cacheDir.listSync(recursive: true); // 파일 목록 가져오기
      for (var file in files) {
        if (file is File) {
          print("File: ${file.path}, Size: ${file.lengthSync()} bytes"); // 파일 경로와 크기 출력
        }
      }
      return _getTotalSizeOfDirectory(cacheDir); // 디렉토리 크기 계산
    } catch (e) {
      print("Error retrieving cache size: $e");
      return 0; // 오류 발생 시 0 반환
    }
  }


  // 디렉토리 크기 계산 함수
  int _getTotalSizeOfDirectory(Directory dir) {
    int totalSize = 0;
    if (dir.existsSync()) {
      for (var file in dir.listSync(recursive: true)) {
        if (file is File) {
          totalSize += file.lengthSync(); // 파일 크기를 누적
        }
      }
    }
    return totalSize;
  }

  // 캐시 데이터 삭제
  Future<void> clearAllCache() async {
    await _clearFileCache(); // 파일 기반 캐시 삭제
    await _clearPreferences(); // SharedPreferences 삭제
  }

  // 파일 기반 캐시 삭제
  Future<void> _clearFileCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
        print("Temporary cache directory cleared.");
      }
    } catch (e) {
      print("Error clearing file cache: $e");
    }
  }

  // SharedPreferences 데이터 삭제
  Future<void> _clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print("Shared preferences cleared.");
    } catch (e) {
      print("Error clearing shared preferences: $e");
    }
  }
}


