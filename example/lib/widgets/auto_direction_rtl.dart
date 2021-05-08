import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';

class AutoDirectionRTL extends StatelessWidget {
  final Widget? child;
  final String text;
  final bool isRTL;

  const AutoDirectionRTL(
      {required this.text, this.child, this.isRTL = false});

  @override
  Widget build(BuildContext context) {
    return AutoDirection(
        text: text.isNotEmpty ? text : isRTL ? "א" : "a",
        child: child ?? Container(),
    );
  }
}