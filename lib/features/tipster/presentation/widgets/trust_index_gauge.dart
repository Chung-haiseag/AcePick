import 'package:flutter/material.dart';
import 'package:acepick/features/tipster/data/models/tipster_model.dart';

/// 신뢰도 지수 게이지 위젯
///
/// TrustIndex를 원형 게이지로 시각적으로 표시합니다.
/// 신뢰도 점수에 따라 색상이 변경됩니다:
/// - 80 이상: 녹색 (높음)
/// - 60~80: 주황색 (중간)
/// - 60 미만: 빨간색 (낮음)
class TrustIndexGauge extends StatelessWidget {
  /// 신뢰도 지수 정보
  final TrustIndex trustIndex;

  /// 게이지 크기 (기본값: 120)
  final double size;

  /// 선 두께 (기본값: 10)
  final double strokeWidth;

  const TrustIndexGauge({
    super.key,
    required this.trustIndex,
    this.size = 120,
    this.strokeWidth = 10,
  });

  /// 신뢰도 점수에 따른 색상을 반환합니다
  Color _getScoreColor(double score) {
    if (score >= 80) {
      return Colors.green;      // 높은 신뢰도
    } else if (score >= 60) {
      return Colors.orange;     // 중간 신뢰도
    } else {
      return Colors.red;        // 낮은 신뢰도
    }
  }

  @override
  Widget build(BuildContext context) {
    // 점수를 0.0~1.0 범위로 정규화
    final normalizedScore = (trustIndex.score / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 원형 프로그레스 인디케이터
          CircularProgressIndicator(
            value: normalizedScore,
            strokeWidth: strokeWidth,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getScoreColor(trustIndex.score),
            ),
          ),
          // 중앙 텍스트
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 점수 숫자
                Text(
                  trustIndex.score.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                // 라벨
                const Text(
                  'Trust Index',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
