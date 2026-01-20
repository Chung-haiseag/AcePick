import '../features/feature_extractor.dart';
import '../../../features/race/data/models/kra/kra_race_result_response.dart';
import '../../../features/race/data/models/race_model.dart';

class RuleBasedPredictor {
  /// KRA 데이터로부터 AI 예측 수행
  static List<AIPrediction> predict(List<KraRaceItem> kraItems) {
    if (kraItems.isEmpty) {
      return [];
    }

    print('🤖 AI Prediction started for ${kraItems.length} horses');

    // 1. Feature 추출
    final features = FeatureExtractor.extractFeatures(kraItems);

    // 2. 점수 기반 정렬
    features.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    // 3. 예측 순위 및 신뢰도 계산
    final predictions = <AIPrediction>[];
    for (int i = 0; i < features.length; i++) {
      final feature = features[i];
      final rank = i + 1;
      
      // 신뢰도 계산: 1위는 높고, 순위가 낮아질수록 감소
      final confidence = _calculateConfidence(
        rank: rank,
        totalScore: feature.totalScore,
        totalHorses: features.length,
      );

      predictions.add(AIPrediction(
        rank: rank,
        confidence: confidence,
      ));

      print('  ${rank}위: ${feature.horseName} '
          '(점수: ${feature.totalScore.toStringAsFixed(3)}, '
          '신뢰도: ${(confidence * 100).toInt()}%)');
    }

    print('✅ AI Prediction completed');
    return predictions;
  }

  /// 신뢰도 계산
  /// 
  /// - 1위: 높은 신뢰도 (0.75~0.95)
  /// - 2-3위: 중간 신뢰도 (0.55~0.75)
  /// - 4위 이하: 낮은 신뢰도 (0.35~0.55)
  static double _calculateConfidence({
    required int rank,
    required double totalScore,
    required int totalHorses,
  }) {
    // 기본 신뢰도: 순위 기반
    double baseConfidence;
    if (rank == 1) {
      baseConfidence = 0.85;
    } else if (rank <= 3) {
      baseConfidence = 0.65;
    } else if (rank <= 5) {
      baseConfidence = 0.50;
    } else {
      baseConfidence = 0.40;
    }

    // 점수 기반 조정 (±0.10)
    final scoreAdjustment = (totalScore - 0.5) * 0.2;

    // 최종 신뢰도
    final confidence = baseConfidence + scoreAdjustment;

    return confidence.clamp(0.30, 0.95);
  }

  /// 예측 정확도 평가 (실제 결과와 비교)
  static Map<String, dynamic> evaluate({
    required List<AIPrediction> predictions,
    required List<int> actualRanks,
  }) {
    if (predictions.length != actualRanks.length) {
      throw Exception('Prediction and actual ranks length mismatch');
    }

    int exactMatches = 0;
    int top3Matches = 0;
    double totalError = 0.0;

    for (int i = 0; i < predictions.length; i++) {
      final predicted = predictions[i].rank;
      final actual = actualRanks[i];

      // 정확히 일치
      if (predicted == actual) {
        exactMatches++;
      }

      // Top 3 안에 있는지
      if (predicted <= 3 && actual <= 3) {
        top3Matches++;
      }

      // MAE (Mean Absolute Error)
      totalError += (predicted - actual).abs();
    }

    final accuracy = exactMatches / predictions.length;
    final top3Accuracy = top3Matches / predictions.length;
    final mae = totalError / predictions.length;

    return {
      'accuracy': accuracy,
      'top3_accuracy': top3Accuracy,
      'mae': mae,
      'exact_matches': exactMatches,
      'total': predictions.length,
    };
  }

  /// Feature 중요도 분석
  static Map<String, double> analyzeFeatureImportance(
    List<HorseFeatures> features,
    List<int> actualRanks,
  ) {
    // TODO: 실제 Feature 중요도 계산
    // 현재는 설정된 가중치 반환
    return {
      'odds': 0.35,
      'weight': 0.10,
      'gate': 0.08,
      'burden': 0.12,
      'acceleration': 0.15,
      'jockey': 0.12,
      'trainer': 0.08,
    };
  }
}
