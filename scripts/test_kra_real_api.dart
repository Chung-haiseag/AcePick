import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  print('🧪 KRA API 테스트 시작\n');

  // API 정보
  final serviceKey = '725f86c2e72ae4a10847e854827113c9959f61084843ef23d20934173f8418af';
  final baseUrl = 'https://apis.data.go.kr/B551015/API4_3';
  
  // 테스트 파라미터 (최근 날짜로 변경 필요)
  final testDate = '20240113'; // 2024년 1월 13일 토요일
  final testMeet = '1'; // 서울
  final testRcNo = '1'; // 1경주

  // URL 생성
  final url = '$baseUrl/raceResult_3'
      '?ServiceKey=$serviceKey'
      '&numOfRows=10'
      '&pageNo=1'
      '&meet=$testMeet'
      '&rc_date=$testDate'
      '&rc_no=$testRcNo'
      '&_type=json';

  print('📡 Request URL:');
  print('$url\n');

  try {
    // API 호출
    final response = await http.get(Uri.parse(url));
    
    print('📊 Response Status: ${response.statusCode}');
    print('📦 Response Headers:');
    response.headers.forEach((key, value) {
      print('  $key: $value');
    });
    print('');

    if (response.statusCode == 200) {
      // JSON 파싱
      final jsonData = jsonDecode(response.body);
      
      print('✅ JSON Response:');
      print(JsonEncoder.withIndent('  ').convert(jsonData));
      print('');

      // 데이터 추출
      final resultCode = jsonData['response']['header']['resultCode'];
      final resultMsg = jsonData['response']['header']['resultMsg'];
      
      print('📋 Result Code: $resultCode');
      print('📋 Result Message: $resultMsg');
      print('');

      if (resultCode == '00') {
        final body = jsonData['response']['body'];
        final totalCount = body['totalCount'];
        final items = body['items'];

        print('🏇 Total Count: $totalCount');
        print('');

        if (items != null && items['item'] != null) {
          final itemList = items['item'] is List 
              ? items['item'] 
              : [items['item']];

          print('📝 First Race Item:');
          final firstItem = itemList[0];
          print('  마명: ${firstItem['hrName']}');
          print('  기수: ${firstItem['jkName']}');
          print('  순위: ${firstItem['ord']}');
          print('  기록: ${firstItem['rcTime']}');
          print('  배당: ${firstItem['winOdds']}');
          print('  경마장: ${firstItem['meet']}');
          print('');

          print('✅ API 테스트 성공!');
        } else {
          print('⚠️  해당 날짜에 경주 데이터가 없습니다.');
        }
      } else {
        print('❌ API Error: $resultMsg');
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}
