import 'package:flutter/material.dart';

/// 신뢰도 표시 바 위젯
///
/// 0.0~1.0 범위의 신뢰도 값을 시각적으로 표시합니다.
/// 신뢰도에 따라 색상이 변경됩니다:
/// - 0.8 이상: 녹색 (높음)
/// - 0.6~0.8: 주황색 (중간)
/// - 0.6 미만: 빨간색 (낮음)
class ConfidenceBar extends StatelessWidget {
  /// 신뢰도 값 (0.0~1.0)
  final double confidence;

  /// 바의 높이 (기본값: 8)
  final double height;

  /// 배경색 (기본값: Colors.grey[300])
  final Color? backgroundColor;

  /// 모서리 반경 (기본값: 4)
  final double borderRadius;

  const ConfidenceBar({
    super.key,
    required this.confidence,
    this.height = 8,
    this.backgroundColor,
    this.borderRadius = 4,
  });

  /// 신뢰도에 따른 색상을 반환합니다
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 신뢰도 값을 0.0~1.0 범위로 제한
    final clampedConfidence = confidence.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: LinearProgressIndicator(
        value: clampedConfidence,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(
          _getConfidenceColor(clampedConfidence),
        ),
      ),
    );
  }
}
