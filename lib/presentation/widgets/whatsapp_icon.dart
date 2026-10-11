import 'package:flutter/material.dart';

/// WhatsApp brand icon (green circle + chat bubble).
class WhatsAppIcon extends StatelessWidget {
  const WhatsAppIcon({super.key, this.size = 24});

  final double size;

  static const Color brandGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: brandGreen,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.chat_bubble,
        color: Colors.white,
        size: size * 0.52,
      ),
    );
  }
}
