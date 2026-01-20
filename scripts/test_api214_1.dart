import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// API214_1 테스트 스크립트
Future<void> main() async {
  print('🧪 API214_1 테스트 시작\n');

  // API 정보
  final serviceKey = '725f86c2e72ae4a10847e854827113c9959f61084843ef23d20934173f8418af';
  final baseUrl = 'https://apis.data.go.kr/B551015/API214_1';
  
  // 테스트 파라미터
  final testDate = '20240113'; // 2024년 1월 13일 토요일
  final testMeet = '1'; // 서울
  final testRcNo = '1'; // 1경주

  // URL 생성
  final url = '$baseUrl/RaceDetailResult_1'
      '?ServiceKey=$serviceKey'
      '&_type=json'
      '&numOfRows=10'
      '&pageNo=1'
      '&meet=$testMeet'
      '&rc_date=$testDate'
      '&rc_no=$testRcNo';

  print('📡 Request URL:');
  print(url.replaceAll(serviceKey, '${serviceKey.substring(0, 20)}...'));
  print('');

  try {
    // HTTP 요청
    final stopwatch = Stopwatch()..start();
    final response = await http.get(Uri.parse(url));
    stopwatch.stop();

    print('📊 Response Status: ${response.statusCode}');
    print('⏱️  Response Time: ${stopwatch.elapsedMilliseconds}ms');
    print('📦 Response Headers:');
    response.headers.forEach((key, value) {
      if (key == 'content-type' || key == 'transfer-encoding' || key == 'date') {
        print('  $key: $value');
      }
    });
    print('');

    if (response.statusCode == 200) {
      // JSON 파싱
      final jsonData = jsonDecode(response.body);
      
      // Response 구조 확인
      print('📋 Response Structure:');
      print('  Keys: ${jsonData.keys.toList()}');
      print('');

      // Header 확인
      final header = jsonData['response']['header'];
      print('📋 Result Code: ${header['resultCode']}');
      print('📋 Result Message: ${header['resultMsg']}');
      print('');

      if (header['resultCode'] == '00') {
        // Body 확인
        final body = jsonData['response']['body'];
        print('🏇 Total Count: ${body['totalCount']}');
        print('📄 Page No: ${body['pageNo']}');
        print('📄 Num Of Rows: ${body['numOfRows']}');
        print('');

        // Items 확인
        final items = body['items'];
        if (items != null && items['item'] != null) {
          final itemList = items['item'] is List 
              ? items['item'] 
              : [items['item']];
          
          print('📝 First Race Item:');
          final first = itemList[0];
          print('  마명: ${first['hrName']}');
          print('  기수: ${first['jkName']}');
          print('  순위: ${first['ord']}');
          print('  기록: ${first['rcTime']}');
          print('  배당: ${first['winOdds']}');
          print('  경마장: ${first['meet']}');
          print('  경주일자: ${first['rcDate']}');
          print('  경주번호: ${first['rcNo']}');
          print('');

          // 전체 JSON 출력 (포맷팅)
          print('📄 Full JSON Response:');
          final prettyJson = JsonEncoder.withIndent('  ').convert(jsonData);
          print(prettyJson);
        } else {
          print('⚠️  No items found');
        }
      } else {
        print('❌ API Error: ${header['resultCode']} - ${header['resultMsg']}');
      }

      print('');
      print('✅ API214_1 테스트 성공!');
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack Trace: $stackTrace');
  }
}
