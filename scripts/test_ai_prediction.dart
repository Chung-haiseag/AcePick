import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  print('🧪 AI Prediction Accuracy Test\n');

  // API 설정
  final serviceKey = '725f86c2e72ae4a10847e854827113c9959f61084843ef23d20934173f8418af';
  final baseUrl = 'https://apis.data.go.kr/B551015/API214_1';

  // 테스트할 과거 경주들 (실제 결과가 있는 날짜)
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

        // Feature 기반 점수 계산 (간단 버전)
        final predictions = _simplePrediction(itemList);

        // 실제 순위
        final actualRanks = itemList
            .map((item) => int.parse(item['ord'].toString()))
            .toList();

        // 평가
        for (int i = 0; i < predictions.length; i++) {
          final predicted = predictions[i];
          final actual = actualRanks[i];

          if (predicted == actual) {
            exactMatches++;
          }

          if (predicted <= 3 && actual <= 3) {
            top3Matches++;
          }

          totalError += (predicted - actual).abs();
        }

        totalRaces += predictions.length;

        print('  ✅ Processed ${predictions.length} horses');
        print('     Exact: ${predictions.where((p) => p == actualRanks[predictions.indexOf(p)]).length}');
        print('     Top 3: ${predictions.where((p) => p <= 3 && actualRanks[predictions.indexOf(p)] <= 3).length}\n');
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
  
  if (accuracy >= 30) {
    print('✅ Accuracy: 양호 (${accuracy.toStringAsFixed(1)}% >= 30%)');
  } else {
    print('⚠️  Accuracy: 개선 필요 (${accuracy.toStringAsFixed(1)}% < 30%)');
  }
  
  if (top3Accuracy >= 50) {
    print('✅ Top 3 Accuracy: 우수 (${top3Accuracy.toStringAsFixed(1)}% >= 50%)');
  } else {
    print('⚠️  Top 3 Accuracy: 개선 필요 (${top3Accuracy.toStringAsFixed(1)}% < 50%)');
  }
}

/// 간단한 예측 로직 (배당률 기반)
List<int> _simplePrediction(List<dynamic> items) {
  // 배당률로 정렬 (낮을수록 1위)
  final sortedItems = List.from(items);
  sortedItems.sort((a, b) {
    final oddsA = double.parse(a['winOdds'].toString());
    final oddsB = double.parse(b['winOdds'].toString());
    return oddsA.compareTo(oddsB);
  });

  // 예측 순위 생성
  final predictions = <int>[];
  for (var item in items) {
    final hrNo = item['hrNo'];
    final rank = sortedItems.indexWhere((i) => i['hrNo'] == hrNo) + 1;
    predictions.add(rank);
  }

  return predictions;
}
