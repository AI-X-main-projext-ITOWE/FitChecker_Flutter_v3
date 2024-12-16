import 'package:flutter/material.dart';
import '../components/cache_management.dart';

class CacheManagementScreen extends StatefulWidget {
  const CacheManagementScreen({Key? key}) : super(key: key);

  @override
  _CacheManagementScreenState createState() => _CacheManagementScreenState();
}

class _CacheManagementScreenState extends State<CacheManagementScreen> {
  final CacheManager _cacheManager = CacheManager(); // CacheManager 인스턴스 생성
  int _cacheSize = 0; // 캐시 크기 (바이트)

  @override
  void initState() {
    super.initState();
    _loadCacheSize(); // 초기 캐시 크기 로드
  }

  // 캐시 크기 로드
  Future<void> _loadCacheSize() async {
    final size = await _cacheManager.getCacheSize();
    setState(() {
      _cacheSize = size;
    });
  }

  // 캐시 삭제 후 상태 갱신
  // 캐시 삭제 후 상태 갱신
  Future<void> _clearCache() async {
    await _cacheManager.clearAllCache(); // 캐시 삭제
    await _loadCacheSize(); // 삭제 후 캐시 크기 갱신

    // 화면 중앙에 메시지 표시
    _showTopMessage("캐시가 삭제되었습니다.");
  }

// 화면 중앙 메시지 출력 메서드
  void _showTopMessage(String message) {
    OverlayState overlayState = Overlay.of(context)!;
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("캐시 관리"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "현재 캐시 크기: ${(_cacheSize / 1024 / 1024).toStringAsFixed(2)} MB",
              style: const TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearCache,
              child: const Text("캐시 삭제"),
            ),
          ],
        ),
      ),
    );
  }
}
