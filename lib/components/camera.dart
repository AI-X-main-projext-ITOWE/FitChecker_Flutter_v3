import 'package:fitchecker/main.dart';
import 'package:fitchecker/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Camera extends StatefulWidget {

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  static const platform = MethodChannel('com.example.camerax_demo/camera');

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      // 네이티브 화면 실행
      await platform.invokeMethod('openNativeScreen');

      // 네이티브 화면 실행 후 Flutter 메인 화면으로 자동 전환
      _navigateToMain();
    } on PlatformException catch (e) {
      print("Failed to start camera: ${e.message}");
    }
  }

  void _navigateToMain() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // 이전 화면으로 이동
    } else {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(), // 적절한 화면으로 이동 수정예정
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AndroidView(
          viewType: 'camera_preview',
          layoutDirection: TextDirection.ltr,
          creationParams: <String, dynamic>{},
          creationParamsCodec: const StandardMessageCodec(),
        ),
      ),
    );
  }
}