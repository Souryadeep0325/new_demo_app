import 'package:flutter/material.dart';
class CentredView extends StatelessWidget {
  final Widget child;
  const CentredView({super.key,required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black),
      padding: const EdgeInsets.symmetric(horizontal: 100),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1200),
      child: child,),
    );
  }
}
