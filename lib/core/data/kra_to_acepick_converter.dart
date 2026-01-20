import '../../features/race/data/models/race_model.dart';
import '../../features/race/data/models/kra/kra_race_result_response.dart';

class KraToAcepickConverter {
  /// KraRaceItem 리스트를 RaceModel 리스트로 변환
  static List<RaceModel> convertRaces(List<KraRaceItem> kraItems) {
    // 경주별로 그룹화
    final Map<String, List<KraRaceItem>> raceGroups = {};

    for (var item in kraItems) {
      final key = '${item.rcDate}_${item.meet}_${item.rcNo}';
      raceGroups.putIfAbsent(key, () => []);
      raceGroups[key]!.add(item);
    }

    // 각 그룹을 RaceModel로 변환
    final List<RaceModel> races = [];
    for (var entry in raceGroups.entries) {
      try {
        final race = _convertSingleRace(entry.value);
        races.add(race);
      } catch (e) {
        print('⚠️  Failed to convert race ${entry.key}: $e');
      }
    }

    return races;
  }

  /// 단일 경주 변환
  static RaceModel _convertSingleRace(List<KraRaceItem> items) {
    if (items.isEmpty) {
      throw Exception('No items to convert');
    }

    final first = items.first;

    // 경주 기본 정보
    final raceId = '${first.rcDate}_${first.meet}_${first.rcNo.toString().padLeft(2, '0')}';
    final date = _formatDate(first.rcDate);

    // 출전마 리스트 변환
    final entries = items.map((item) => _convertHorseEntry(item)).toList();

    // AI 예측 순위로 정렬 (현재는 실제 순위 사용)
    entries.sort((a, b) => a.aiPrediction.rank.compareTo(b.aiPrediction.rank));

    return RaceModel(
      raceId: raceId,
      raceDate: date,
      raceNumber: first.rcNo,
      raceName: first.rcName.isNotEmpty ? first.rcName : '${first.rcNo}경주',
      raceTime: '00:00', // KRA API에서 제공하지 않음
      track: first.meet,
      distance: first.rcDist,
      horses: entries,
      weather: first.weather.isNotEmpty ? first.weather : '알 수 없음',
      trackCondition: first.track.isNotEmpty ? first.track : '알 수 없음',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  /// 출전마 정보 변환
  static HorseEntry _convertHorseEntry(KraRaceItem item) {
    // 구간 기록 계산
    final sectionalTimes = _calculateSectionalTimes(item);
    
    // 혈통 정보 (현재는 더미)
    final pedigree = Pedigree(
      sire: '',
      dam: '',
      sireWinRate: 0.0,
    );

    // AI 예측 (현재는 실제 결과 사용)
    final aiPrediction = AIPrediction(
      rank: item.ord,
      confidence: _calculateConfidence(item),
    );

    return HorseEntry(
      horseId: item.hrNo,
      horseName: item.hrName,
      jockey: item.jkName,
      trainer: item.trName,
      gate: item.chulNo,
      odds: item.winOdds,
      weight: _parseWeight(item.wgHr),
      recentForm: [], // 과거 성적은 별도 API 필요
      pedigree: pedigree,
      sectionalTimes: sectionalTimes,
      aiPrediction: aiPrediction,
    );
  }

  /// 구간 기록 계산
  static SectionalTimes _calculateSectionalTimes(KraRaceItem item) {
    final first600m = item.seS1fAccTime;
    final second600m = item.seG3fAccTime > 0 
        ? item.seG3fAccTime - item.seS1fAccTime 
        : 0.0;
    final last600m = item.seG1fAccTime > 0 
        ? item.seG1fAccTime - item.seG3fAccTime 
        : 0.0;

    final accelerationScore = _calculateAccelerationScore(
      first600m,
      second600m,
      last600m,
    );

    return SectionalTimes(
      first600m: first600m,
      second600m: second600m,
      last600m: last600m,
      accelerationScore: accelerationScore,
    );
  }

  /// 가속도 점수 계산
  static double _calculateAccelerationScore(
    double first,
    double second,
    double last,
  ) {
    if (last == 0 || first == 0) return 0.0;

    // 마지막 구간이 빠를수록 높은 점수
    final avgFirst = (first + second) / 2;
    final score = (avgFirst - last) / avgFirst;

    return score.clamp(0.0, 1.0);
  }

  /// 신뢰도 계산 (임시: 1위에 가까울수록 높음)
  static double _calculateConfidence(KraRaceItem item) {
    // 실제 순위 기반 임시 신뢰도
    final baseConfidence = 1.0 - (item.ord - 1) * 0.1;
    return baseConfidence.clamp(0.3, 0.95);
  }

  /// 날짜 포맷 변환 (YYYYMMDD → YYYY-MM-DD)
  static String _formatDate(String kraDate) {
    if (kraDate.length != 8) return kraDate;
    return '${kraDate.substring(0, 4)}-${kraDate.substring(4, 6)}-${kraDate.substring(6, 8)}';
  }

  /// 마체중 파싱 (예: "502(-2)" → 502)
  static int _parseWeight(String wgHr) {
    final match = RegExp(r'\d+').firstMatch(wgHr);
    return match != null ? int.parse(match.group(0)!) : 0;
  }
}
