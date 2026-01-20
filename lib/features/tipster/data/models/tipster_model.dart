// 경마 팁스터 데이터 모델 클래스들
//
// 포함되는 클래스:
// - TipsterModel: 팁스터 정보
// - TrustIndex: 신뢰도 지수
// - TrustIndexComponents: 신뢰도 지수 구성 요소
// - TipsterStats: 팁스터 통계
// - RecentPick: 최근 예측 기록

/// 팁스터 정보를 나타내는 모델 클래스
///
/// 경마 팁스터의 기본 정보, 신뢰도, 통계, 최근 예측을 포함합니다.
class TipsterModel {
  /// 팁스터 고유 ID (예: TIP_00038)
  final String tipsterId;

  /// 팁스터 사용자명 (예: 경마 과학자)
  final String username;

  /// 팁스터 검증 여부
  /// true: 공식 검증된 팁스터
  /// false: 미검증 팁스터
  final bool verified;

  /// 팁스터의 신뢰도 지수
  final TrustIndex trustIndex;

  /// 팁스터의 통계 정보
  final TipsterStats stats;

  /// 최근 20개의 예측 기록
  final List<RecentPick> recentPicks;

  /// 데이터 생성 시간 (ISO 8601 형식)
  final String createdAt;

  /// TipsterModel 생성자
  TipsterModel({
    required this.tipsterId,
    required this.username,
    required this.verified,
    required this.trustIndex,
    required this.stats,
    required this.recentPicks,
    required this.createdAt,
  });

  /// JSON 맵에서 TipsterModel 인스턴스 생성
  ///
  /// [json] JSON 맵 데이터
  /// 반환: TipsterModel 인스턴스
  factory TipsterModel.fromJson(Map<String, dynamic> json) {
    return TipsterModel(
      tipsterId: json['tipster_id'] as String,
      username: json['username'] as String,
      verified: json['verified'] as bool,
      trustIndex: TrustIndex.fromJson(json['trust_index'] as Map<String, dynamic>),
      stats: TipsterStats.fromJson(json['stats'] as Map<String, dynamic>),
      recentPicks: (json['recent_picks'] as List<dynamic>)
          .map((pick) => RecentPick.fromJson(pick as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
    );
  }

  /// TipsterModel을 JSON 맵으로 변환
  ///
  /// 반환: JSON 형식의 맵
  Map<String, dynamic> toJson() {
    return {
      'tipster_id': tipsterId,
      'username': username,
      'verified': verified,
      'trust_index': trustIndex.toJson(),
      'stats': stats.toJson(),
      'recent_picks': recentPicks.map((pick) => pick.toJson()).toList(),
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'TipsterModel(tipsterId: $tipsterId, username: $username, verified: $verified, trustScore: ${trustIndex.score})';
  }
}

/// 팁스터의 신뢰도 지수를 나타내는 모델 클래스
///
/// 신뢰도 점수, 구성 요소, Brier Score, ROI를 포함합니다.
class TrustIndex {
  /// 신뢰도 점수 (40~95 사이의 값)
  /// 높을수록 더 신뢰할 수 있는 팁스터
  final double score;

  /// 신뢰도 지수의 구성 요소
  final TrustIndexComponents components;

  /// Brier Score (0.1~0.4 사이의 값)
  /// 예측의 정확도를 나타내는 지표
  /// 낮을수록 예측이 정확함
  final double brierScore;

  /// 수익률 (Return On Investment, -15.0~25.0 사이의 값)
  /// 예: 23.33은 23.33% 수익률을 의미
  final double roi;

  /// TrustIndex 생성자
  TrustIndex({
    required this.score,
    required this.components,
    required this.brierScore,
    required this.roi,
  });

  /// JSON 맵에서 TrustIndex 인스턴스 생성
  ///
  /// [json] JSON 맵 데이터
  /// 반환: TrustIndex 인스턴스
  factory TrustIndex.fromJson(Map<String, dynamic> json) {
    return TrustIndex(
      score: (json['score'] as num).toDouble(),
      components: TrustIndexComponents.fromJson(
          json['components'] as Map<String, dynamic>),
      brierScore: (json['brier_score'] as num).toDouble(),
      roi: (json['roi'] as num).toDouble(),
    );
  }

  /// TrustIndex를 JSON 맵으로 변환
  ///
  /// 반환: JSON 형식의 맵
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'components': components.toJson(),
      'brier_score': brierScore,
      'roi': roi,
    };
  }

  @override
  String toString() {
    return 'TrustIndex(score: $score, brierScore: $brierScore, roi: $roi)';
  }
}

/// 신뢰도 지수의 구성 요소를 나타내는 모델 클래스
///
/// 정확도, 일관성, 예측량, 투명성 등의 세부 지표를 포함합니다.
class TrustIndexComponents {
  /// 정확도 (0.4~0.9 사이의 값)
  /// 팁스터의 예측 정확도를 나타냄
  /// 예: 0.8은 80% 정확도를 의미
  final double accuracy;

  /// 일관성 (0.5~0.95 사이의 값)
  /// 팁스터의 예측 일관성을 나타냄
  /// 높을수록 더 일관된 성과를 보임
  final double consistency;

  /// 예측량 (50~500 사이의 값)
  /// 팁스터가 제공한 예측의 개수
  /// 많을수록 더 많은 데이터 포인트를 가짐
  final int volume;

  /// 투명성 (0.7~1.0 사이의 값)
  /// 팁스터의 정보 공개 정도
  /// 높을수록 더 투명한 정보 제공
  final double transparency;

  /// TrustIndexComponents 생성자
  TrustIndexComponents({
    required this.accuracy,
    required this.consistency,
    required this.volume,
    required this.transparency,
  });

  /// JSON 맵에서 TrustIndexComponents 인스턴스 생성
  ///
  /// [json] JSON 맵 데이터
  /// 반환: TrustIndexComponents 인스턴스
  factory TrustIndexComponents.fromJson(Map<String, dynamic> json) {
    return TrustIndexComponents(
      accuracy: (json['accuracy'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
      volume: json['volume'] as int,
      transparency: (json['transparency'] as num).toDouble(),
    );
  }

  /// TrustIndexComponents를 JSON 맵으로 변환
  ///
  /// 반환: JSON 형식의 맵
  Map<String, dynamic> toJson() {
    return {
      'accuracy': accuracy,
      'consistency': consistency,
      'volume': volume,
      'transparency': transparency,
    };
  }

  @override
  String toString() {
    return 'TrustIndexComponents(accuracy: $accuracy, consistency: $consistency, volume: $volume, transparency: $transparency)';
  }
}

/// 팁스터의 통계 정보를 나타내는 모델 클래스
///
/// 총 예측 수, 우승, 입상, 팔로워 수 등의 통계를 포함합니다.
class TipsterStats {
  /// 총 예측 수 (50~500 사이의 값)
  /// 팁스터가 제공한 전체 예측의 개수
  final int totalPredictions;

  /// 우승 횟수
  /// 팁스터의 예측이 1위로 정확히 맞은 횟수
  final int wins;

  /// 입상 횟수
  /// 팁스터의 예측이 상위권에 들어간 횟수
  final int places;

  /// 총 팔로워 수
  /// 팁스터를 팔로우하는 사용자의 수
  final int totalFollowers;

  /// TipsterStats 생성자
  TipsterStats({
    required this.totalPredictions,
    required this.wins,
    required this.places,
    required this.totalFollowers,
  });

  /// JSON 맵에서 TipsterStats 인스턴스 생성
  ///
  /// [json] JSON 맵 데이터
  /// 반환: TipsterStats 인스턴스
  factory TipsterStats.fromJson(Map<String, dynamic> json) {
    return TipsterStats(
      totalPredictions: json['total_predictions'] as int,
      wins: json['wins'] as int,
      places: json['places'] as int,
      totalFollowers: json['total_followers'] as int,
    );
  }

  /// TipsterStats를 JSON 맵으로 변환
  ///
  /// 반환: JSON 형식의 맵
  Map<String, dynamic> toJson() {
    return {
      'total_predictions': totalPredictions,
      'wins': wins,
      'places': places,
      'total_followers': totalFollowers,
    };
  }

  /// 우승률 계산 (%)
  ///
  /// 반환: 우승률 (0~100 사이의 값)
  double getWinRate() {
    if (totalPredictions == 0) return 0.0;
    return (wins / totalPredictions) * 100;
  }

  /// 입상률 계산 (%)
  ///
  /// 반환: 입상률 (0~100 사이의 값)
  double getPlaceRate() {
    if (totalPredictions == 0) return 0.0;
    return (places / totalPredictions) * 100;
  }

  @override
  String toString() {
    return 'TipsterStats(totalPredictions: $totalPredictions, wins: $wins, places: $places, totalFollowers: $totalFollowers)';
  }
}

/// 팁스터의 최근 예측 기록을 나타내는 모델 클래스
///
/// 경주 ID, 예측 순위, 실제 순위, 타임스탬프를 포함합니다.
class RecentPick {
  /// 경주 고유 ID (예: R20260131_01)
  final String raceId;

  /// 팁스터가 예측한 순위 (1~12 사이의 값)
  final int predictedRank;

  /// 실제 경주 결과 순위 (1~12 사이의 값)
  final int actualRank;

  /// 예측 시간 (ISO 8601 형식)
  final String timestamp;

  /// RecentPick 생성자
  RecentPick({
    required this.raceId,
    required this.predictedRank,
    required this.actualRank,
    required this.timestamp,
  });

  /// JSON 맵에서 RecentPick 인스턴스 생성
  ///
  /// [json] JSON 맵 데이터
  /// 반환: RecentPick 인스턴스
  factory RecentPick.fromJson(Map<String, dynamic> json) {
    return RecentPick(
      raceId: json['race_id'] as String,
      predictedRank: json['predicted_rank'] as int,
      actualRank: json['actual_rank'] as int,
      timestamp: json['timestamp'] as String,
    );
  }

  /// RecentPick을 JSON 맵으로 변환
  ///
  /// 반환: JSON 형식의 맵
  Map<String, dynamic> toJson() {
    return {
      'race_id': raceId,
      'predicted_rank': predictedRank,
      'actual_rank': actualRank,
      'timestamp': timestamp,
    };
  }

  /// 예측이 정확한지 확인
  ///
  /// 반환: true이면 예측이 정확함, false이면 부정확함
  bool isAccurate() {
    return predictedRank == actualRank;
  }

  /// 예측 오차 계산 (순위 차이)
  ///
  /// 반환: 예측 순위와 실제 순위의 차이
  int getErrorMargin() {
    return (predictedRank - actualRank).abs();
  }

  @override
  String toString() {
    return 'RecentPick(raceId: $raceId, predictedRank: $predictedRank, actualRank: $actualRank)';
  }
}
