import '../../../features/race/data/models/kra/kra_race_result_response.dart';

/// AI 예측을 위한 Feature Map
class HorseFeatures {
  // 기본 정보
  final String horseId;
  final String horseName;
  
  // 수치형 Features
  final double oddsFeature;           // 배당률 (낮을수록 우승 확률 높음)
  final double weightFeature;         // 마체중 정규화
  final double gateFeature;           // 출주 게이트 (중간이 유리)
  final double burdenFeature;         // 부담중량
  final double accelerationFeature;   // 가속도 점수
  final double jockeyWinRate;         // 기수 승률 (더미)
  final double trainerWinRate;        // 조교사 승률 (더미)
  
  // 복합 점수
  final double totalScore;

  HorseFeatures({
    required this.horseId,
    required this.horseName,
    required this.oddsFeature,
    required this.weightFeature,
    required this.gateFeature,
    required this.burdenFeature,
    required this.accelerationFeature,
    required this.jockeyWinRate,
    required this.trainerWinRate,
    required this.totalScore,
  });
}

class FeatureExtractor {
  /// KraRaceItem 리스트에서 Feature 추출
  static List<HorseFeatures> extractFeatures(List<KraRaceItem> items) {
    if (items.isEmpty) return [];

    // 정규화를 위한 통계 계산
    final stats = _calculateStats(items);

    return items.map((item) => _extractSingleFeature(item, stats, items.length)).toList();
  }

  /// 단일 말의 Feature 추출
  static HorseFeatures _extractSingleFeature(
    KraRaceItem item,
    Map<String, double> stats,
    int totalHorses,
  ) {
    // 1. 배당률 Feature (역수 사용, 낮을수록 좋음)
    final oddsFeature = _normalizeOdds(item.winOdds, stats);

    // 2. 마체중 Feature (최적 체중 범위: 490-520kg)
    final weight = _parseWeight(item.wgHr);
    final weightFeature = _normalizeWeight(weight);

    // 3. 게이트 Feature (중간 게이트가 유리)
    final gateFeature = _normalizeGate(item.chulNo, totalHorses);

    // 4. 부담중량 Feature (가벼울수록 유리)
    final burdenFeature = _normalizeBurden(item.wgBudam, stats);

    // 5. 가속도 Feature (구간 기록 기반)
    final accelerationFeature = _calculateAcceleration(item);

    // 6. 기수 승률 (실제 데이터 없으므로 더미)
    final jockeyWinRate = _getDummyJockeyRate(item.jkNo);

    // 7. 조교사 승률 (실제 데이터 없으므로 더미)
    final trainerWinRate = _getDummyTrainerRate(item.trNo);

    // 8. 가중치 적용한 총점 계산
    final totalScore = _calculateTotalScore(
      oddsFeature: oddsFeature,
      weightFeature: weightFeature,
      gateFeature: gateFeature,
      burdenFeature: burdenFeature,
      accelerationFeature: accelerationFeature,
      jockeyWinRate: jockeyWinRate,
      trainerWinRate: trainerWinRate,
    );

    return HorseFeatures(
      horseId: item.hrNo,
      horseName: item.hrName,
      oddsFeature: oddsFeature,
      weightFeature: weightFeature,
      gateFeature: gateFeature,
      burdenFeature: burdenFeature,
      accelerationFeature: accelerationFeature,
      jockeyWinRate: jockeyWinRate,
      trainerWinRate: trainerWinRate,
      totalScore: totalScore,
    );
  }

  /// 통계 계산 (정규화용)
  static Map<String, double> _calculateStats(List<KraRaceItem> items) {
    final odds = items.map((i) => i.winOdds).toList();
    final burdens = items.map((i) => i.wgBudam).toList();

    return {
      'oddsMin': odds.reduce((a, b) => a < b ? a : b),
      'oddsMax': odds.reduce((a, b) => a > b ? a : b),
      'burdenMin': burdens.reduce((a, b) => a < b ? a : b),
      'burdenMax': burdens.reduce((a, b) => a > b ? a : b),
      'avgOdds': odds.reduce((a, b) => a + b) / odds.length,
    };
  }

  /// 배당률 정규화 (낮을수록 1에 가까움)
  static double _normalizeOdds(double odds, Map<String, double> stats) {
    final min = stats['oddsMin']!;
    final max = stats['oddsMax']!;
    
    if (max == min) return 0.5;
    
    // 역정규화 (낮은 배당 = 높은 점수)
    return 1.0 - (odds - min) / (max - min);
  }

  /// 마체중 정규화 (490-520kg이 최적)
  static double _normalizeWeight(int weight) {
    if (weight == 0) return 0.5;

    final optimal = 505.0; // 최적 체중
    final deviation = (weight - optimal).abs();

    // 편차가 클수록 점수 낮음
    if (deviation <= 10) return 1.0;
    if (deviation <= 20) return 0.8;
    if (deviation <= 30) return 0.6;
    return 0.4;
  }

  /// 게이트 정규화 (중간이 유리)
  static double _normalizeGate(int gate, int totalGates) {
    if (totalGates == 0) return 0.5;

    final middle = totalGates / 2;
    final deviation = (gate - middle).abs();

    // 중앙에서 멀어질수록 점수 낮음
    return 1.0 - (deviation / middle).clamp(0.0, 1.0);
  }

  /// 부담중량 정규화 (가벼울수록 유리)
  static double _normalizeBurden(double burden, Map<String, double> stats) {
    final min = stats['burdenMin']!;
    final max = stats['burdenMax']!;
    
    if (max == min) return 0.5;
    
    // 가벼울수록 높은 점수
    return 1.0 - (burden - min) / (max - min);
  }

  /// 가속도 계산
  static double _calculateAcceleration(KraRaceItem item) {
    final s1f = item.seS1fAccTime;
    final g3f = item.seG3fAccTime;
    final g1f = item.seG1fAccTime;

    if (g1f == 0 || s1f == 0) return 0.5;

    // 후반부가 빠를수록 높은 점수
    final firstHalf = g3f - s1f;
    final secondHalf = g1f - g3f;

    if (firstHalf <= 0) return 0.5;

    final acceleration = (firstHalf - secondHalf) / firstHalf;
    return acceleration.clamp(0.0, 1.0);
  }

  /// 더미 기수 승률
  static double _getDummyJockeyRate(String jkNo) {
    // TODO: 실제 DB에서 조회
    final hash = jkNo.hashCode.abs();
    return 0.3 + (hash % 40) / 100; // 0.3~0.7
  }

  /// 더미 조교사 승률
  static double _getDummyTrainerRate(String trNo) {
    // TODO: 실제 DB에서 조회
    final hash = trNo.hashCode.abs();
    return 0.25 + (hash % 35) / 100; // 0.25~0.6
  }

  /// 가중치 적용 총점 계산
  static double _calculateTotalScore({
    required double oddsFeature,
    required double weightFeature,
    required double gateFeature,
    required double burdenFeature,
    required double accelerationFeature,
    required double jockeyWinRate,
    required double trainerWinRate,
  }) {
    // 가중치 (총합 1.0)
    const weights = {
      'odds': 0.35,        // 배당률이 가장 중요
      'weight': 0.10,
      'gate': 0.08,
      'burden': 0.12,
      'acceleration': 0.15,
      'jockey': 0.12,
      'trainer': 0.08,
    };

    return oddsFeature * weights['odds']! +
        weightFeature * weights['weight']! +
        gateFeature * weights['gate']! +
        burdenFeature * weights['burden']! +
        accelerationFeature * weights['acceleration']! +
        jockeyWinRate * weights['jockey']! +
        trainerWinRate * weights['trainer']!;
  }

  /// 마체중 파싱
  static int _parseWeight(String wgHr) {
    final match = RegExp(r'\d+').firstMatch(wgHr);
    return match != null ? int.parse(match.group(0)!) : 0;
  }
}
