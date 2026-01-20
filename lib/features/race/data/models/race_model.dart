// 경마 경주 데이터 모델 클래스들
//
// 포함되는 클래스:
// - RaceModel: 경주 정보
// - HorseEntry: 출전 말 정보
// - Pedigree: 혈통 정보
// - SectionalTimes: 구간 기록
// - AIPrediction: AI 예측 정보

/// 경주 정보를 나타내는 모델 클래스
/// 
/// 경마 경주의 기본 정보와 출전 말들의 정보를 포함합니다.
class RaceModel {
  /// 경주 고유 ID (예: R20260131_01)
  final String raceId;

  /// 경주 날짜 (YYYY-MM-DD 형식)
  final String raceDate;

  /// 경주 번호 (1~12)
  final int raceNumber;

  /// 경주명 (예: 01월 31일 1경주)
  final String raceName;

  /// 경주 시간 (HH:MM 형식)
  final String raceTime;

  /// 경마장 (예: 서울경마장, 부산경마장)
  final String track;

  /// 경주 거리 (미터 단위, 일반적으로 1800m)
  final int distance;

  /// 출전 말들의 정보 리스트
  final List<HorseEntry> horses;

  /// 경주 당일 날씨 (예: 맑음, 흐림, 약간의 비)
  final String weather;

  /// 마장 상태 (예: 양호, 보통, 불량)
  final String trackCondition;

  /// 데이터 생성 시간 (ISO 8601 형식)
  final String createdAt;

  /// RaceModel 생성자
  RaceModel({
    required this.raceId,
    required this.raceDate,
    required this.raceNumber,
    required this.raceName,
    required this.raceTime,
    required this.track,
    required this.distance,
    required this.horses,
    required this.weather,
    required this.trackCondition,
    required this.createdAt,
  });

  /// JSON 맵에서 RaceModel 인스턴스 생성
  /// 
  /// [json] JSON 맵 데이터
  /// 반환: RaceModel 인스턴스
  factory RaceModel.fromJson(Map<String, dynamic> json) {
    return RaceModel(
      raceId: json['race_id'] as String,
      raceDate: json['race_date'] as String,
      raceNumber: json['race_number'] as int,
      raceName: json['race_name'] as String,
      raceTime: json['race_time'] as String,
      track: json['track'] as String,
      distance: json['distance'] as int,
      horses: (json['horses'] as List<dynamic>)
          .map((horse) => HorseEntry.fromJson(horse as Map<String, dynamic>))
          .toList(),
      weather: json['weather'] as String,
      trackCondition: json['track_condition'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  /// RaceModel을 JSON 맵으로 변환
  /// 
  /// 반환: JSON 형식의 맵
  Map<String, dynamic> toJson() {
    return {
      'race_id': raceId,
      'race_date': raceDate,
      'race_number': raceNumber,
      'race_name': raceName,
      'race_time': raceTime,
      'track': track,
      'distance': distance,
      'horses': horses.map((horse) => horse.toJson()).toList(),
      'weather': weather,
      'track_condition': trackCondition,
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'RaceModel(raceId: $raceId, raceName: $raceName, track: $track, horses: ${horses.length})';
  }
}

/// 출전 말의 정보를 나타내는 모델 클래스
/// 
/// 각 경주에 출전하는 말의 상세 정보를 포함합니다.
class HorseEntry {
  /// 말 고유 ID (예: H2024_202601310101)
  final String horseId;

  /// 말의 이름 (예: 경주마764호)
  final String horseName;

  /// 기수 이름
  final String jockey;

  /// 조교사 이름
  final String trainer;

  /// 게이트 번호 (1~12)
  final int gate;

  /// 배당률 (1.8~35.0 사이의 값)
  final double odds;

  /// 말의 체중 (kg 단위, 일반적으로 480~540kg)
  final int weight;

  /// 최근 전적 (최근 5경주의 순위)
  /// 예: [5, 1, 7, 8, 6] - 1등, 7등, 8등, 6등, 5등
  final List<int> recentForm;

  /// 말의 혈통 정보
  final Pedigree pedigree;

  /// 말의 구간 기록
  final SectionalTimes sectionalTimes;

  /// AI 예측 정보
  final AIPrediction aiPrediction;

  /// HorseEntry 생성자
  HorseEntry({
    required this.horseId,
    required this.horseName,
    required this.jockey,
    required this.trainer,
    required this.gate,
    required this.odds,
    required this.weight,
    required this.recentForm,
    required this.pedigree,
    required this.sectionalTimes,
    required this.aiPrediction,
  });

  /// JSON 맵에서 HorseEntry 인스턴스 생성
  /// 
  /// [json] JSON 맵 데이터
  /// 반환: HorseEntry 인스턴스
  factory HorseEntry.fromJson(Map<String, dynamic> json) {
    return HorseEntry(
      horseId: json['horse_id'] as String,
      horseName: json['horse_name'] as String,
      jockey: json['jockey'] as String,
      trainer: json['trainer'] as String,
      gate: json['gate'] as int,
      odds: (json['odds'] as num).toDouble(),
      weight: json['weight'] as int,
      recentForm: List<int>.from(json['recent_form'] as List<dynamic>),
      pedigree: Pedigree.fromJson(json['pedigree'] as Map<String, dynamic>),
      sectionalTimes: SectionalTimes.fromJson(
          json['sectional_times'] as Map<String, dynamic>),
      aiPrediction:
          AIPrediction.fromJson(json['ai_prediction'] as Map<String, dynamic>),
    );
  }

  /// HorseEntry를 JSON 맵으로 변환
  /// 
  /// 반환: JSON 형식의 맵
  Map<String, dynamic> toJson() {
    return {
      'horse_id': horseId,
      'horse_name': horseName,
      'jockey': jockey,
      'trainer': trainer,
      'gate': gate,
      'odds': odds,
      'weight': weight,
      'recent_form': recentForm,
      'pedigree': pedigree.toJson(),
      'sectional_times': sectionalTimes.toJson(),
      'ai_prediction': aiPrediction.toJson(),
    };
  }

  @override
  String toString() {
    return 'HorseEntry(horseId: $horseId, horseName: $horseName, gate: $gate, odds: $odds)';
  }
}

/// 말의 혈통 정보를 나타내는 모델 클래스
/// 
/// 부마, 모마, 부마의 우승률 정보를 포함합니다.
class Pedigree {
  /// 부마 (아버지 말) 이름
  final String sire;

  /// 모마 (어머니 말) 이름
  final String dam;

  /// 부마의 우승률 (0.0~1.0 사이의 값)
  /// 예: 0.318은 31.8% 우승률을 의미
  final double sireWinRate;

  /// Pedigree 생성자
  Pedigree({
    required this.sire,
    required this.dam,
    required this.sireWinRate,
  });

  /// JSON 맵에서 Pedigree 인스턴스 생성
  /// 
  /// [json] JSON 맵 데이터
  /// 반환: Pedigree 인스턴스
  factory Pedigree.fromJson(Map<String, dynamic> json) {
    return Pedigree(
      sire: json['sire'] as String,
      dam: json['dam'] as String,
      sireWinRate: (json['sire_win_rate'] as num).toDouble(),
    );
  }

  /// Pedigree를 JSON 맵으로 변환
  /// 
  /// 반환: JSON 형식의 맵
  Map<String, dynamic> toJson() {
    return {
      'sire': sire,
      'dam': dam,
      'sire_win_rate': sireWinRate,
    };
  }

  @override
  String toString() {
    return 'Pedigree(sire: $sire, dam: $dam, sireWinRate: $sireWinRate)';
  }
}

/// 말의 구간 기록을 나타내는 모델 클래스
/// 
/// 경주 중 각 구간별 시간 기록과 가속도 점수를 포함합니다.
class SectionalTimes {
  /// 첫 번째 600m 구간 기록 (초 단위)
  /// 예: 38.78은 38.78초를 의미
  final double first600m;

  /// 두 번째 600m 구간 기록 (초 단위)
  final double second600m;

  /// 마지막 600m 구간 기록 (초 단위)
  /// 일반적으로 가장 빠른 구간
  final double last600m;

  /// 가속도 점수 (50~100 사이의 값)
  /// 높을수록 마지막 구간에서 더 빠르게 가속했음을 의미
  final double accelerationScore;

  /// SectionalTimes 생성자
  SectionalTimes({
    required this.first600m,
    required this.second600m,
    required this.last600m,
    required this.accelerationScore,
  });

  /// JSON 맵에서 SectionalTimes 인스턴스 생성
  /// 
  /// [json] JSON 맵 데이터
  /// 반환: SectionalTimes 인스턴스
  factory SectionalTimes.fromJson(Map<String, dynamic> json) {
    return SectionalTimes(
      first600m: (json['first_600m'] as num).toDouble(),
      second600m: (json['second_600m'] as num).toDouble(),
      last600m: (json['last_600m'] as num).toDouble(),
      accelerationScore: (json['acceleration_score'] as num).toDouble(),
    );
  }

  /// SectionalTimes를 JSON 맵으로 변환
  /// 
  /// 반환: JSON 형식의 맵
  Map<String, dynamic> toJson() {
    return {
      'first_600m': first600m,
      'second_600m': second600m,
      'last_600m': last600m,
      'acceleration_score': accelerationScore,
    };
  }

  /// 전체 경주 시간 계산 (3개 구간의 합)
  /// 
  /// 반환: 전체 경주 시간 (초 단위)
  double getTotalTime() {
    return first600m + second600m + last600m;
  }

  @override
  String toString() {
    return 'SectionalTimes(first600m: $first600m, second600m: $second600m, last600m: $last600m, accelerationScore: $accelerationScore)';
  }
}

/// AI 예측 정보를 나타내는 모델 클래스
/// 
/// 머신러닝 모델의 예측 순위와 신뢰도를 포함합니다.
class AIPrediction {
  /// AI 예측 순위 (1~12 사이의 값)
  /// 1이 가장 높은 확률로 우승할 것으로 예측한 순위
  final int rank;

  /// 예측의 신뢰도 (0.0~1.0 사이의 값)
  /// 예: 0.839는 83.9% 신뢰도를 의미
  /// 값이 높을수록 모델이 자신감 있게 예측함
  final double confidence;

  /// AIPrediction 생성자
  AIPrediction({
    required this.rank,
    required this.confidence,
  });

  /// JSON 맵에서 AIPrediction 인스턴스 생성
  /// 
  /// [json] JSON 맵 데이터
  /// 반환: AIPrediction 인스턴스
  factory AIPrediction.fromJson(Map<String, dynamic> json) {
    return AIPrediction(
      rank: json['rank'] as int,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  /// AIPrediction을 JSON 맵으로 변환
  /// 
  /// 반환: JSON 형식의 맵
  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'confidence': confidence,
    };
  }

  @override
  String toString() {
    return 'AIPrediction(rank: $rank, confidence: $confidence)';
  }
}
