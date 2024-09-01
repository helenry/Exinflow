import 'package:flutter/material.dart';

class AllPadding extends StatelessWidget {
  final Widget child;

  AllPadding({Key? key, required this.child}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: child,
    );
  }
}