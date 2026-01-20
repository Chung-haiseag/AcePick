import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// RuleBasedPredictor를 사용하기 위해 필요한 import
// 실제로는 패키지 구조에 맞게 import 경로 조정 필요

Future<void> main() async {
  print('🧪 AI Prediction Accuracy Test (RuleBased)\n');

  // API 설정
  final serviceKey = '725f86c2e72ae4a10847e854827113c9959f61084843ef23d20934173f8418af';
  final baseUrl = 'https://apis.data.go.kr/B551015/API214_1';

  // 테스트할 과거 경주들
  final testRaces = [
    {'date': '20240113', 'meet': '1', 'rcNo': '1'},
    {'date': '20240113', 'meet': '1', 'rcNo': '2'},
    {'date': '20240113', 'meet': '1', 'rcNo': '3'},
    {'date': '20240113', 'meet': '1', 'rcNo': '4'},
    {'date': '20240113', 'meet': '1', 'rcNo': '5'},
  ];

  int totalRaces = 0;
  int exactMatches = 0;
  int top3Matches = 0;
  double totalError = 0.0;

  for (var race in testRaces) {
    print('📍 Testing: ${race['date']} ${race['meet']}경마장 ${race['rcNo']}경주');

    try {
      // 경주 데이터 가져오기
      final url = '$baseUrl/RaceDetailResult_1'
          '?ServiceKey=$serviceKey'
          '&numOfRows=20'
          '&pageNo=1'
          '&meet=${race['meet']}'
          '&rc_date=${race['date']}'
          '&rc_no=${race['rcNo']}'
          '&_type=json';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final items = jsonData['response']['body']['items']['item'];

        if (items == null) {
          print('  ⚠️  No data\n');
          continue;
        }

        final itemList = items is List ? items : [items];

        // Feature 기반 예측 (RuleBased 로직 시뮬레이션)
        final predictions = _ruleBasedPrediction(itemList);

        // 실제 순위
        final actualRanks = itemList
            .map((item) => int.parse(item['ord'].toString()))
            .toList();

        // 평가
        int raceExact = 0;
        int raceTop3 = 0;
        
        for (int i = 0; i < predictions.length; i++) {
          final predicted = predictions[i]['rank'] as int;
          final actual = actualRanks[i];

          if (predicted == actual) {
            exactMatches++;
            raceExact++;
          }

          if (predicted <= 3 && actual <= 3) {
            top3Matches++;
            raceTop3++;
          }

          totalError += (predicted - actual).abs();
        }

        totalRaces += predictions.length;

        print('  ✅ Processed ${predictions.length} horses');
        print('     Exact: $raceExact (${(raceExact / predictions.length * 100).toStringAsFixed(1)}%)');
        print('     Top 3: $raceTop3 (${(raceTop3 / predictions.length * 100).toStringAsFixed(1)}%)');
        
        // Feature 추출 로그
        print('     📊 Feature Sample (1st horse):');
        final firstHorse = predictions[0];
        print('        - Odds: ${firstHorse['odds']}');
        print('        - Weight: ${firstHorse['weight']}');
        print('        - Gate: ${firstHorse['gate']}');
        print('        - Score: ${firstHorse['score'].toStringAsFixed(3)}');
        print('');
      }
    } catch (e) {
      print('  ❌ Error: $e\n');
    }
  }

  // 결과 출력
  print('═══════════════════════════');
  print('📊 Test Results');
  print('═══════════════════════════');
  print('Total Horses: $totalRaces');
  print('Exact Matches: $exactMatches');
  print('Accuracy: ${(exactMatches / totalRaces * 100).toStringAsFixed(1)}%');
  print('Top 3 Matches: $top3Matches');
  print('Top 3 Accuracy: ${(top3Matches / totalRaces * 100).toStringAsFixed(1)}%');
  print('MAE: ${(totalError / totalRaces).toStringAsFixed(2)}');
  print('═══════════════════════════');
  
  // 평가
  print('\n📈 Evaluation:');
  final accuracy = exactMatches / totalRaces * 100;
  final top3Accuracy = top3Matches / totalRaces * 100;
  final mae = totalError / totalRaces;
  
  print('\n목표 달성 여부:');
  
  if (accuracy >= 30) {
    print('✅ Accuracy: 목표 달성 (${accuracy.toStringAsFixed(1)}% >= 30%)');
  } else {
    print('❌ Accuracy: 목표 미달 (${accuracy.toStringAsFixed(1)}% < 30%)');
  }
  
  if (top3Accuracy >= 50) {
    print('✅ Top 3 Accuracy: 목표 달성 (${top3Accuracy.toStringAsFixed(1)}% >= 50%)');
  } else {
    print('❌ Top 3 Accuracy: 목표 미달 (${top3Accuracy.toStringAsFixed(1)}% < 50%)');
  }
  
  if (mae <= 2.0) {
    print('✅ MAE: 목표 달성 (${mae.toStringAsFixed(2)} <= 2.0)');
  } else {
    print('❌ MAE: 목표 미달 (${mae.toStringAsFixed(2)} > 2.0)');
  }
}

/// 규칙 기반 예측 (7개 Feature 사용)
List<Map<String, dynamic>> _ruleBasedPrediction(List<dynamic> items) {
  // Feature 추출 및 정규화
  final features = <Map<String, dynamic>>[];
  
  // 통계 계산
  final oddsList = items.map((i) => double.tryParse(i['winOdds']?.toString() ?? '1.0') ?? 1.0).toList();
  final weightList = items.map((i) => double.tryParse(i['hrWght']?.toString() ?? '500') ?? 500).toList();
  final gateList = items.map((i) => int.tryParse(i['gate']?.toString() ?? '5') ?? 5).toList();
  final burdenList = items.map((i) => double.tryParse(i['brdnWght']?.toString() ?? '55') ?? 55).toList();
  
  final minOdds = oddsList.reduce((a, b) => a < b ? a : b);
  final maxOdds = oddsList.reduce((a, b) => a > b ? a : b);
  final minWeight = weightList.reduce((a, b) => a < b ? a : b);
  final maxWeight = weightList.reduce((a, b) => a > b ? a : b);
  final minGate = gateList.reduce((a, b) => a < b ? a : b);
  final maxGate = gateList.reduce((a, b) => a > b ? a : b);
  final minBurden = burdenList.reduce((a, b) => a < b ? a : b);
  final maxBurden = burdenList.reduce((a, b) => a > b ? a : b);
  
  for (var item in items) {
    final odds = double.tryParse(item['winOdds']?.toString() ?? '1.0') ?? 1.0;
    final weight = double.tryParse(item['hrWght']?.toString() ?? '500') ?? 500;
    final gate = int.tryParse(item['gate']?.toString() ?? '5') ?? 5;
    final burden = double.tryParse(item['brdnWght']?.toString() ?? '55') ?? 55;
    
    // Feature 정규화
    final oddsFeature = _normalizeOdds(odds, minOdds, maxOdds);
    final weightFeature = _normalizeWeight(weight, minWeight, maxWeight);
    final gateFeature = _normalizeGate(gate, minGate, maxGate);
    final burdenFeature = _normalizeBurden(burden, minBurden, maxBurden);
    
    // 가속도 점수 (구간 기록 기반)
    final accelerationFeature = _calculateAcceleration(item);
    
    // 기수/조교사 승률 (더미)
    final jockeyRate = 0.5;
    final trainerRate = 0.5;
    
    // 가중치 적용 총점 계산
    final score = 
        oddsFeature * 0.35 +
        weightFeature * 0.15 +
        gateFeature * 0.10 +
        burdenFeature * 0.10 +
        accelerationFeature * 0.15 +
        jockeyRate * 0.10 +
        trainerRate * 0.05;
    
    features.add({
      'hrNo': item['hrNo'],
      'hrName': item['hrName'],
      'odds': odds,
      'weight': weight,
      'gate': gate,
      'burden': burden,
      'score': score,
      'oddsFeature': oddsFeature,
      'weightFeature': weightFeature,
      'gateFeature': gateFeature,
      'burdenFeature': burdenFeature,
      'accelerationFeature': accelerationFeature,
    });
  }
  
  // 점수로 정렬 (내림차순)
  features.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
  
  // 예측 순위 할당
  final predictions = <Map<String, dynamic>>[];
  for (var item in items) {
    final hrNo = item['hrNo'];
    final rank = features.indexWhere((f) => f['hrNo'] == hrNo) + 1;
    final feature = features.firstWhere((f) => f['hrNo'] == hrNo);
    
    predictions.add({
      'hrNo': hrNo,
      'hrName': item['hrName'],
      'rank': rank,
      'score': feature['score'],
      'odds': feature['odds'],
      'weight': feature['weight'],
      'gate': feature['gate'],
    });
  }
  
  return predictions;
}

/// 배당률 정규화 (역정규화: 낮을수록 높은 점수)
double _normalizeOdds(double odds, double min, double max) {
  if (max == min) return 0.5;
  final normalized = (odds - min) / (max - min);
  return 1.0 - normalized;  // 역정규화
}

/// 마체중 정규화 (적정 체중 중심)
double _normalizeWeight(double weight, double min, double max) {
  if (max == min) return 0.5;
  final normalized = (weight - min) / (max - min);
  // 중간값(0.5)에 가까울수록 높은 점수
  return 1.0 - (normalized - 0.5).abs() * 2;
}

/// 게이트 정규화 (중간 게이트 유리)
double _normalizeGate(int gate, int min, int max) {
  if (max == min) return 0.5;
  final normalized = (gate - min) / (max - min);
  // 중간값(0.5)에 가까울수록 높은 점수
  return 1.0 - (normalized - 0.5).abs() * 2;
}

/// 부담중량 정규화 (낮을수록 유리)
double _normalizeBurden(double burden, double min, double max) {
  if (max == min) return 0.5;
  final normalized = (burden - min) / (max - min);
  return 1.0 - normalized;  // 역정규화
}

/// 가속도 점수 계산 (구간 기록 기반)
double _calculateAcceleration(Map<String, dynamic> item) {
  try {
    final s1f = double.tryParse(item['s1f']?.toString() ?? '0') ?? 0;
    final s2f = double.tryParse(item['s2f']?.toString() ?? '0') ?? 0;
    final s3f = double.tryParse(item['s3f']?.toString() ?? '0') ?? 0;
    
    if (s1f == 0 || s2f == 0 || s3f == 0) return 0.5;
    
    // 후반 가속 (3구간이 빠를수록 높은 점수)
    final acceleration = (s1f + s2f) / (2 * s3f);
    
    // 0.5~1.5 범위를 0~1로 정규화
    return ((acceleration - 0.5) / 1.0).clamp(0.0, 1.0);
  } catch (e) {
    return 0.5;
  }
}
