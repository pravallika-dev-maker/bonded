import 'package:flutter/material.dart';

class AppHeartIcon extends StatelessWidget {
  final double size;

  const AppHeartIcon({
    super.key,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1F0611),
        border: Border.all(
          color: const Color(0xFF5A1630),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF911746).withOpacity(0.18),
            blurRadius: size * 0.5,
            spreadRadius: size * 0.15,
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // 1. Outer Stroke (Light Pink)
            Text(
              String.fromCharCode(Icons.favorite.codePoint),
              style: TextStyle(
                fontSize: size * 0.46,
                fontFamily: Icons.favorite.fontFamily,
                package: Icons.favorite.fontPackage,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 4.0
                  ..color = const Color(0xFFCA366C),
              ),
            ),
            // 2. The Gap (Background Color)
            Text(
              String.fromCharCode(Icons.favorite.codePoint),
              style: TextStyle(
                fontSize: size * 0.46,
                fontFamily: Icons.favorite.fontFamily,
                package: Icons.favorite.fontPackage,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2.0
                  ..color = const Color(0xFF1F0611),
              ),
            ),
            // 3. The Inner Filled Heart (Dark Pink)
            Text(
              String.fromCharCode(Icons.favorite.codePoint),
              style: TextStyle(
                fontSize: size * 0.46,
                fontFamily: Icons.favorite.fontFamily,
                package: Icons.favorite.fontPackage,
                color: const Color(0xFF8F1643),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
