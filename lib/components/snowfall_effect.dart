import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class Snowflake {
  double x;
  double y;
  double size;
  double speed;
  double drift; // 좌우 흔들림 정도

  Snowflake({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
  });
}

class SnowfallEffect extends StatefulWidget {
  final double width;
  final double height;

  const SnowfallEffect({required this.width, required this.height, Key? key}) : super(key: key);

  @override
  _SnowfallEffectState createState() => _SnowfallEffectState();
}

class _SnowfallEffectState extends State<SnowfallEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Snowflake> _snowflakes;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100), // 프레임 속도 감소 (천천히 움직임)
    )..addListener(_updateSnowflakes);

    _snowflakes = List.generate(
      100, // 눈송이 개수 감소
          (_) => _createSnowflake(widget.width, widget.height),
    );

    _controller.repeat();
  }

  Snowflake _createSnowflake(double width, double height) {
    return Snowflake(
      x: _random.nextDouble() * width,
      y: _random.nextDouble() * height,
      size: _random.nextDouble() * 2 + 1, // 눈송이 크기 작게 (1~2)
      speed: _random.nextDouble() * 1.5 + 0.5, // 속도 줄임 (0.5~1.5)
      drift: _random.nextDouble() * 0.5 - 0.25, // 좌우 흔들림 (-0.25~0.25)
    );
  }

  void _updateSnowflakes() {
    setState(() {
      for (var snowflake in _snowflakes) {
        snowflake.y += snowflake.speed; // 아래로 이동
        snowflake.x += snowflake.drift; // 좌우로 살짝 흔들림

        // 화면 아래로 사라지면 다시 위에서 생성
        if (snowflake.y > widget.height) {
          snowflake.y = 0;
          snowflake.x = _random.nextDouble() * widget.width;
        }

        // 화면 밖으로 나가면 x 좌표를 조정
        if (snowflake.x < 0) {
          snowflake.x = widget.width;
        } else if (snowflake.x > widget.width) {
          snowflake.x = 0;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SnowPainter(_snowflakes),
      child: Container(
        width: widget.width,
        height: widget.height,
      ),
    );
  }
}

class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;

  SnowPainter(this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);

    for (var snowflake in snowflakes) {
      canvas.drawCircle(
        Offset(snowflake.x, snowflake.y),
        snowflake.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}