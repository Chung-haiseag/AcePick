import '../models/race_model.dart';
import '../../../../core/api/kra_api_service.dart';
import '../../../../core/api/kra_api_config.dart';
import '../../../../core/ai/prediction_service.dart';
import '../models/kra/kra_race_result_response.dart';
import 'race_repository.dart';

class KraRaceRepository implements RaceRepository {
  final KraApiService _apiService = KraApiService();
  final PredictionService _predictionService = PredictionService();

  @override
  Future<List<RaceModel>> getRaces(String date) async {
    try {
      final kraDate = date.replaceAll('-', '');
      print('🔍 Fetching races for $kraDate');
      
      final kraItems = await _apiService.getAllRacesForDate(kraDate);
      
      if (kraItems.isEmpty) {
        print('⚠️  No races found for $kraDate');
        return [];
      }

      // 경주별로 그룹화
      final raceGroups = _groupByRace(kraItems);
      
      // 각 경주를 RaceModel로 변환 (AI 예측 포함)
      final races = <RaceModel>[];
      for (var entry in raceGroups.entries) {
        try {
          final race = await _convertSingleRaceWithAI(entry.value);
          races.add(race);
        } catch (e) {
          print('⚠️  Failed to convert race ${entry.key}: $e');
        }
      }
      
      print('✅ Converted ${races.length} races with AI predictions');
      return races;
    } catch (e) {
      print('❌ Error fetching races: $e');
      return [];
    }
  }

  @override
  Future<RaceModel> getRaceDetail(String raceId) async {
    // raceId: "20220220_서울_01"
    final parts = raceId.split('_');
    if (parts.length != 3) {
      throw Exception('Invalid race ID format');
    }

    final date = parts[0];
    final meetName = parts[1];
    final rcNo = parts[2];

    // 경마장 이름 → 코드 변환
    final meetCode = KraApiConfig.MEET_CODES[meetName] ?? '1';

    final response = await _apiService.getRaceResult(
      meet: meetCode,
      rcDate: date,
      rcNo: rcNo,
    );

    return await _convertSingleRaceWithAI(response.body.items);
  }

  @override
  Future<List<RaceModel>> getUpcomingRaces(int days) async {
    final now = DateTime.now();
    final List<RaceModel> allRaces = [];

    for (int i = 0; i < days; i++) {
      final date = now.add(Duration(days: i));
      final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
      
      final races = await getRaces(dateStr);
      allRaces.addAll(races);
    }

    return allRaces;
  }

  /// 경주별로 그룹화
  Map<String, List<KraRaceItem>> _groupByRace(List<KraRaceItem> items) {
    final Map<String, List<KraRaceItem>> groups = {};
    
    for (var item in items) {
      final key = '${item.rcDate}_${item.meet}_${item.rcNo}';
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(item);
    }
    
    return groups;
  }

  /// 단일 경주 변환 (AI 예측 포함)
  Future<RaceModel> _convertSingleRaceWithAI(
    List<KraRaceItem> kraItems
  ) async {
    if (kraItems.isEmpty) {
      throw Exception('No items to convert');
    }

    final first = kraItems.first;

    // 1. AI 예측 수행
    print('🤖 Predicting race: ${first.meet} ${first.rcNo}경주');
    final predictions = await _predictionService.predictRace(kraItems);

    // 2. KraRaceItem과 예측 결과 매핑
    final itemsWithPredictions = <MapEntry<KraRaceItem, AIPrediction>>[];
    for (int i = 0; i < kraItems.length; i++) {
      itemsWithPredictions.add(MapEntry(kraItems[i], predictions[i]));
    }

    // 3. AI 예측 순위로 정렬
    itemsWithPredictions.sort(
      (a, b) => a.value.rank.compareTo(b.value.rank)
    );

    // 4. HorseEntry 생성
    final entries = itemsWithPredictions.map((entry) {
      return _convertHorseEntry(entry.key, entry.value);
    }).toList();

    // 5. RaceModel 생성
    final raceId = '${first.rcDate}_${first.meet}_${first.rcNo.toString().padLeft(2, '0')}';
    final date = _formatDate(first.rcDate);

    return RaceModel(
      raceId: raceId,
      raceDate: date,
      raceNumber: first.rcNo,
      raceName: first.rcName ?? '${first.rcNo}경주',
      raceTime: '00:00',  // KRA API 미제공
      track: first.meet,
      distance: first.rcDist,
      horses: entries,
      weather: '알 수 없음',  // KRA API 미제공
      trackCondition: '알 수 없음',  // KRA API 미제공
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  /// HorseEntry 변환
  HorseEntry _convertHorseEntry(
    KraRaceItem item,
    AIPrediction prediction,
  ) {
    // 구간 기록
    final sectionalTimes = SectionalTimes(
      first600m: item.seS1fAccTime,
      second600m: item.seG3fAccTime > 0 
          ? item.seG3fAccTime - item.seS1fAccTime 
          : 0.0,
      last600m: item.seG1fAccTime > 0 
          ? item.seG1fAccTime - item.seG3fAccTime 
          : 0.0,
      accelerationScore: _calculateAcceleration(item),
    );

    // 혈통 (더미)
    final pedigree = Pedigree(
      sire: '',
      dam: '',
      sireWinRate: 0.0,
    );

    return HorseEntry(
      horseId: item.hrNo,
      horseName: item.hrName,
      jockey: item.jkName,
      trainer: item.trName,
      gate: item.chulNo,
      odds: item.winOdds,
      weight: _parseWeight(item.wgHr),
      recentForm: [],
      pedigree: pedigree,
      sectionalTimes: sectionalTimes,
      aiPrediction: prediction, // AI 예측 결과 사용
    );
  }

  /// 가속도 계산
  double _calculateAcceleration(KraRaceItem item) {
    if (item.seG1fAccTime == 0 || item.seS1fAccTime == 0) return 0.0;
    final firstHalf = item.seG3fAccTime - item.seS1fAccTime;
    final secondHalf = item.seG1fAccTime - item.seG3fAccTime;
    if (firstHalf <= 0) return 0.0;
    return ((firstHalf - secondHalf) / firstHalf).clamp(0.0, 1.0);
  }

  /// 마체중 파싱
  int _parseWeight(String wgHr) {
    final match = RegExp(r'\d+').firstMatch(wgHr);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  /// 날짜 포맷 변환
  String _formatDate(String kraDate) {
    if (kraDate.length != 8) return kraDate;
    return '${kraDate.substring(0, 4)}-${kraDate.substring(4, 6)}-${kraDate.substring(6, 8)}';
  }
}
