import 'dart:math';
import 'package:flutter/material.dart';

class QrMatrixWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;

  const QrMatrixWidget({
    super.key,
    required this.data,
    this.size = 180,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.15 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _QrMatrixPainter(
          data: data,
          foregroundColor: foregroundColor,
        ),
      ),
    );
  }
}

class _QrMatrixPainter extends CustomPainter {
  final String data;
  final Color foregroundColor;

  _QrMatrixPainter({
    required this.data,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.fill;

    const matrixSize = 25; // 25x25 QR grid
    final cellSize = size.width / matrixSize;

    // Build boolean grid initialized to false
    final grid = List.generate(matrixSize, (_) => List.filled(matrixSize, false));

    // 1. Draw 3 Corner Finder Patterns (7x7 squares at Top-Left, Top-Right, Bottom-Left)
    _drawFinderPattern(grid, 0, 0);
    _drawFinderPattern(grid, matrixSize - 7, 0);
    _drawFinderPattern(grid, 0, matrixSize - 7);

    // 2. Draw Timing tracks (Row 6 and Col 6)
    for (int i = 8; i < matrixSize - 8; i++) {
      grid[6][i] = i % 2 == 0;
      grid[i][6] = i % 2 == 0;
    }

    // 3. Fill data modules using pseudo-random deterministic hash of input data
    final random = Random(data.hashCode.abs());
    for (int r = 0; r < matrixSize; r++) {
      for (int c = 0; c < matrixSize; c++) {
        // Skip finder areas
        if (_isFinderArea(r, c, matrixSize)) continue;
        if (r == 6 || c == 6) continue;

        grid[r][c] = random.nextBool();
      }
    }

    // 4. Render cells onto canvas with smooth rounded rectangles
    for (int r = 0; r < matrixSize; r++) {
      for (int c = 0; c < matrixSize; c++) {
        if (grid[r][c]) {
          final rect = Rect.fromLTWH(
            c * cellSize,
            r * cellSize,
            cellSize * 0.94,
            cellSize * 0.94,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.2)),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(List<List<bool>> grid, int startCol, int startRow) {
    for (int r = 0; r < 7; r++) {
      for (int c = 0; c < 7; c++) {
        // Outer border or center 3x3 block
        final isOuter = r == 0 || r == 6 || c == 0 || c == 6;
        final isInner = r >= 2 && r <= 4 && c >= 2 && c <= 4;
        grid[startRow + r][startCol + c] = isOuter || isInner;
      }
    }
  }

  bool _isFinderArea(int r, int c, int matrixSize) {
    if (r < 8 && c < 8) return true; // Top-Left
    if (r < 8 && c >= matrixSize - 8) return true; // Top-Right
    if (r >= matrixSize - 8 && c < 8) return true; // Bottom-Left
    return false;
  }

  @override
  bool shouldRepaint(covariant _QrMatrixPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.foregroundColor != foregroundColor;
  }
}
