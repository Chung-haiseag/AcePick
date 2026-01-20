import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 간단한 통합 테스트 (패키지 import 없이)
Future<void> main() async {
  print('🧪 KRA API 통합 테스트 시작\n');

  // .env 파일 읽기
  final envFile = File('/home/ubuntu/Documents/AcePick/.env');
  final envContent = await envFile.readAsString();
  
  String? apiKey;
  String? baseUrl;
  
  for (var line in envContent.split('\n')) {
    if (line.startsWith('KRA_API_KEY=')) {
      apiKey = line.split('=')[1].trim();
    } else if (line.startsWith('KRA_BASE_URL=')) {
      baseUrl = line.split('=')[1].trim();
    }
  }

  if (apiKey == null || baseUrl == null) {
    print('❌ .env 파일에서 API 설정을 찾을 수 없습니다.');
    return;
  }

  print('✅ .env 파일 로드 성공');
  print('   API Key: ${apiKey.substring(0, 20)}...');
  print('   Base URL: $baseUrl\n');

  // 테스트 날짜: 2024년 1월 13일 토요일
  final testDate = '20240113';

  // 테스트 1: 단일 경주 조회
  print('📋 테스트 1: 단일 경주 조회 ($testDate)');
  final url1 = '$baseUrl/raceResult_3'
      '?ServiceKey=$apiKey'
      '&_type=json'
      '&numOfRows=10'
      '&pageNo=1'
      '&meet=1'
      '&rc_date=$testDate'
      '&rc_no=1';

  try {
    final stopwatch1 = Stopwatch()..start();
    final response1 = await http.get(Uri.parse(url1));
    stopwatch1.stop();

    print('   Status: ${response1.statusCode}');
    print('   응답 시간: ${stopwatch1.elapsedMilliseconds}ms');

    if (response1.statusCode == 200) {
      final jsonData1 = jsonDecode(response1.body);
      final resultCode = jsonData1['response']['header']['resultCode'];
      final resultMsg = jsonData1['response']['header']['resultMsg'];
      
      print('   Result Code: $resultCode');
      print('   Result Message: $resultMsg');

      if (resultCode == '00') {
        final totalCount = jsonData1['response']['body']['totalCount'];
        print('   Total Count: $totalCount');
        print('   ✅ 테스트 1 성공\n');
      } else {
        print('   ⚠️  API 응답 코드: $resultCode - $resultMsg');
        print('   해당 날짜에 경주가 없을 수 있습니다.\n');
      }
    } else {
      print('   ❌ HTTP Error: ${response1.statusCode}\n');
    }
  } catch (e) {
    print('   ❌ 테스트 1 실패: $e\n');
  }

  // 테스트 2: 특정 날짜 전체 경주 조회
  print('📋 테스트 2: 특정 날짜 전체 경주 조회 (서울 - $testDate)');
  final url2 = '$baseUrl/raceResult_3'
      '?ServiceKey=$apiKey'
      '&_type=json'
      '&numOfRows=100'
      '&pageNo=1'
      '&meet=1'
      '&rc_date=$testDate';

  try {
    final stopwatch2 = Stopwatch()..start();
    final response2 = await http.get(Uri.parse(url2));
    stopwatch2.stop();

    print('   Status: ${response2.statusCode}');
    print('   응답 시간: ${stopwatch2.elapsedMilliseconds}ms');

    if (response2.statusCode == 200) {
      final jsonData2 = jsonDecode(response2.body);
      final resultCode = jsonData2['response']['header']['resultCode'];
      final resultMsg = jsonData2['response']['header']['resultMsg'];
      
      print('   Result Code: $resultCode');
      print('   Result Message: $resultMsg');

      if (resultCode == '00') {
        final totalCount = jsonData2['response']['body']['totalCount'];
        final items = jsonData2['response']['body']['items'];
        
        print('   Total Count: $totalCount');
        
        if (items != null && items['item'] != null) {
          final itemList = items['item'] is List 
              ? items['item'] 
              : [items['item']];
          
          // 경주별로 그룹화
          final Map<int, int> raceGroups = {};
          for (var item in itemList) {
            final rcNo = item['rcNo'] as int;
            raceGroups[rcNo] = (raceGroups[rcNo] ?? 0) + 1;
          }
          
          print('   경주 개수: ${raceGroups.length}개');
          print('   출전마 총합: ${itemList.length}마리');
          print('   경주별 출전마:');
          raceGroups.forEach((rcNo, count) {
            print('     ${rcNo}경주: $count마리');
          });
          print('   ✅ 테스트 2 성공\n');
        } else {
          print('   ⚠️  해당 날짜에 경주 데이터가 없습니다.\n');
        }
      } else {
        print('   ⚠️  API 응답 코드: $resultCode - $resultMsg\n');
      }
    } else {
      print('   ❌ HTTP Error: ${response2.statusCode}\n');
    }
  } catch (e) {
    print('   ❌ 테스트 2 실패: $e\n');
  }

  // 테스트 3: 데이터 구조 검증
  print('📋 테스트 3: 데이터 구조 검증 ($testDate)');
  final url3 = '$baseUrl/raceResult_3'
      '?ServiceKey=$apiKey'
      '&_type=json'
      '&numOfRows=1'
      '&pageNo=1'
      '&meet=1'
      '&rc_date=$testDate'
      '&rc_no=1';

  try {
    final response3 = await http.get(Uri.parse(url3));

    if (response3.statusCode == 200) {
      final jsonData3 = jsonDecode(response3.body);
      final resultCode = jsonData3['response']['header']['resultCode'];
      
      if (resultCode == '00') {
        final items = jsonData3['response']['body']['items'];
        
        if (items != null && items['item'] != null) {
          final item = items['item'] is List 
              ? items['item'][0] 
              : items['item'];
          
          print('   필수 필드 확인:');
          print('     hrNo: ${item['hrNo']}');
          print('     hrName: ${item['hrName']}');
          print('     jkName: ${item['jkName']}');
          print('     trName: ${item['trName']}');
          print('     ord: ${item['ord']}');
          print('     rcTime: ${item['rcTime']}');
          print('     winOdds: ${item['winOdds']}');
          print('     meet: ${item['meet']}');
          print('     rcDate: ${item['rcDate']}');
          print('     rcNo: ${item['rcNo']}');
          print('     rcDist: ${item['rcDist']}');
          print('     weather: ${item['weather']}');
          print('     track: ${item['track']}');
          print('   ✅ 테스트 3 성공\n');
        } else {
          print('   ⚠️  해당 날짜에 경주 데이터가 없습니다.\n');
        }
      } else {
        print('   ⚠️  API 응답 코드: $resultCode\n');
      }
    }
  } catch (e) {
    print('   ❌ 테스트 3 실패: $e\n');
  }

  print('🎉 통합 테스트 완료!');
  print('\n💡 참고: 해당 날짜에 경주가 없다면 다른 주말 날짜로 시도해보세요.');
  print('   예: 20231230 (2023년 12월 30일 토요일)');
  print('   예: 20231231 (2023년 12월 31일 일요일)');
}
