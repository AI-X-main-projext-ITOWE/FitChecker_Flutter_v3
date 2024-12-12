import 'package:flutter/material.dart';

class BouncyText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const BouncyText({Key? key, required this.text, required this.style}) : super(key: key);

  @override
  _BouncyTextState createState() => _BouncyTextState();
}

class _BouncyTextState extends State<BouncyText> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(widget.text.length, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.elasticOut)).animate(controller);
    }).toList();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.text.length, (index) {
        return ScaleTransition(
          scale: _animations[index],
          child: Text(
            widget.text[index],
            style: widget.style,
          ),
        );
      }),
    );
  }
}