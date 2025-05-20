import 'package:flutter/material.dart';
import 'package:cling/core/color.dart'; // 여러분 프로젝트에 맞게 import

class GoogleLoginButton extends StatelessWidget {
  /// 버튼 눌렀을 때 호출될 콜백
  final VoidCallback onPressed;

  /// 버튼 텍스트 (기본: Sign in with Google)
  final String label;

  const GoogleLoginButton({
    Key? key,
    required this.onPressed,
    this.label = 'Sign in with Google',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 구글 로고
            Image.asset(
              'assets/images/google_icon.png',
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: text900Color, // 혹은 Colors.black87
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
