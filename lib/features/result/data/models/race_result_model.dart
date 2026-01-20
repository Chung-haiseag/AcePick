// lib/features/result/data/models/race_result_model.dart

/// 경주 결과 모델
class RaceResult {
  final String raceId;
  final String raceName;
  final DateTime raceDate;
  final String track;
  final int distance;
  final String grade;
  final List<HorseResult> results;
  final Map<String, double> dividends;

  RaceResult({
    required this.raceId,
    required this.raceName,
    required this.raceDate,
    required this.track,
    required this.distance,
    required this.grade,
    required this.results,
    required this.dividends,
  });

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    return RaceResult(
      raceId: json['raceId'] ?? '',
      raceName: json['raceName'] ?? '',
      raceDate: DateTime.parse(json['raceDate']),
      track: json['track'] ?? '',
      distance: json['distance'] ?? 0,
      grade: json['grade'] ?? '',
      results: (json['results'] as List?)
              ?.map((r) => HorseResult.fromJson(r))
              .toList() ??
          [],
      dividends: Map<String, double>.from(json['dividends'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raceId': raceId,
      'raceName': raceName,
      'raceDate': raceDate.toIso8601String(),
      'track': track,
      'distance': distance,
      'grade': grade,
      'results': results.map((r) => r.toJson()).toList(),
      'dividends': dividends,
    };
  }
}

/// 말 결과 모델
class HorseResult {
  final int rank;
  final String horseName;
  final int horseNumber;
  final String jockeyName;
  final String trainerName;
  final double weight;
  final String recordTime;
  final double odds;

  HorseResult({
    required this.rank,
    required this.horseName,
    required this.horseNumber,
    required this.jockeyName,
    required this.trainerName,
    required this.weight,
    required this.recordTime,
    required this.odds,
  });

  factory HorseResult.fromJson(Map<String, dynamic> json) {
    return HorseResult(
      rank: json['rank'] ?? 0,
      horseName: json['horseName'] ?? '',
      horseNumber: json['horseNumber'] ?? 0,
      jockeyName: json['jockeyName'] ?? '',
      trainerName: json['trainerName'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      recordTime: json['recordTime'] ?? '',
      odds: (json['odds'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'horseName': horseName,
      'horseNumber': horseNumber,
      'jockeyName': jockeyName,
      'trainerName': trainerName,
      'weight': weight,
      'recordTime': recordTime,
      'odds': odds,
    };
  }
}
