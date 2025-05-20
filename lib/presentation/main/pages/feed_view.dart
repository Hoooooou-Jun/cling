import 'package:flutter/material.dart';

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: Text(
          '피드',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}
