import 'dart:convert';
import 'dart:io';
import 'lib/features/race/data/models/race_model.dart';

void main() async {
  print('=' * 100);
  print('🧪 RaceModel toJson() 메서드 테스트');
  print('=' * 100);
  print('');

  try {
    // 1. races.json 파일 읽기
    print('📖 races.json 파일 읽기 중...');
    final file = File('assets/mock_data/races.json');
    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString) as List<dynamic>;
    
    print('✓ 파일 읽기 완료');
    print('  - 총 경주 수: ${jsonData.length}');
    print('');

    // 2. 첫 번째 경주 데이터 추출
    print('🏇 첫 번째 경주 데이터 추출 중...');
    final firstRaceJson = jsonData[0] as Map<String, dynamic>;
    print('✓ 원본 JSON 데이터 추출 완료');
    print('');

    // 3. RaceModel로 변환
    print('🔄 JSON → RaceModel 변환 중...');
    final raceModel = RaceModel.fromJson(firstRaceJson);
    print('✓ RaceModel 변환 완료');
    print('  - Race ID: ${raceModel.raceId}');
    print('  - Race Name: ${raceModel.raceName}');
    print('  - Track: ${raceModel.track}');
    print('  - Horses: ${raceModel.horses.length}마리');
    print('');

    // 4. RaceModel을 다시 JSON으로 변환
    print('🔄 RaceModel → JSON 변환 중...');
    final convertedJson = raceModel.toJson();
    print('✓ JSON 변환 완료');
    print('');

    // 5. JSON 문자열로 변환
    print('📝 JSON 문자열로 변환 중...');
    final jsonString2 = jsonEncode(convertedJson);
    print('✓ JSON 문자열 변환 완료');
    print('');

    // 6. 원본과 변환된 JSON 비교
    print('=' * 100);
    print('📊 원본 JSON vs 변환된 JSON 비교');
    print('=' * 100);
    print('');

    final originalJson = jsonEncode(firstRaceJson);
    final originalSize = originalJson.length;
    final convertedSize = jsonString2.length;

    print('📏 파일 크기:');
    print('  - 원본: $originalSize bytes');
    print('  - 변환: $convertedSize bytes');
    print('  - 차이: ${(convertedSize - originalSize).abs()} bytes');
    print('');

    // 7. 동등성 비교
    print('🔍 데이터 동등성 검증:');
    final originalDecoded = jsonDecode(originalJson) as Map<String, dynamic>;
    final convertedDecoded = jsonDecode(jsonString2) as Map<String, dynamic>;
    
    final isEqual = _compareJson(originalDecoded, convertedDecoded);
    print('  - 동등성: ${isEqual ? '✅ 일치' : '❌ 불일치'}');
    print('');

    // 8. 첫 번째 경주의 상세 정보 출력
    print('=' * 100);
    print('📋 첫 번째 경주 변환 결과 (JSON 형식)');
    print('=' * 100);
    print('');
    
    // 보기 좋게 포맷팅
    final prettyJson = JsonEncoder.withIndent('  ').convert(convertedJson);
    
    // 첫 2000자만 출력
    if (prettyJson.length > 2000) {
      print(prettyJson.substring(0, 2000));
      print('');
      print('... (생략) ...');
      print('');
      print('(전체 크기: ${prettyJson.length} 문자)');
    } else {
      print(prettyJson);
    }
    print('');

    // 9. 말 정보 샘플 출력
    print('=' * 100);
    print('🐴 첫 번째 말 정보 (변환된 JSON)');
    print('=' * 100);
    print('');

    final firstHorseJson = convertedJson['horses'][0] as Map<String, dynamic>;
    final firstHorseJsonString = JsonEncoder.withIndent('  ').convert(firstHorseJson);
    print(firstHorseJsonString);
    print('');

    // 10. 요약
    print('=' * 100);
    print('✅ 테스트 완료');
    print('=' * 100);
    print('');
    print('📊 요약:');
    print('  - 경주 ID: ${raceModel.raceId}');
    print('  - 경주명: ${raceModel.raceName}');
    print('  - 경마장: ${raceModel.track}');
    print('  - 거리: ${raceModel.distance}m');
    print('  - 출전 말: ${raceModel.horses.length}마리');
    print('  - 날씨: ${raceModel.weather}');
    print('  - 마장 상태: ${raceModel.trackCondition}');
    print('');
    print('🔄 변환 결과: ${isEqual ? '✅ 성공 (원본과 일치)' : '⚠️ 경고 (원본과 불일치)'}');
    print('');

  } catch (e) {
    print('❌ 에러 발생: $e');
    print('$e');
  }
}

/// JSON 객체 동등성 비교 함수
bool _compareJson(dynamic obj1, dynamic obj2, {int depth = 0}) {
  if (obj1.runtimeType != obj2.runtimeType) {
    print('  타입 불일치: ${obj1.runtimeType} vs ${obj2.runtimeType}');
    return false;
  }

  if (obj1 is Map) {
    final map1 = obj1 as Map<String, dynamic>;
    final map2 = obj2 as Map<String, dynamic>;

    if (map1.keys.length != map2.keys.length) {
      print('  키 개수 불일치: ${map1.keys.length} vs ${map2.keys.length}');
      return false;
    }

    for (final key in map1.keys) {
      if (!map2.containsKey(key)) {
        print('  키 누락: $key');
        return false;
      }

      if (!_compareJson(map1[key], map2[key], depth: depth + 1)) {
        return false;
      }
    }
    return true;
  } else if (obj1 is List) {
    final list1 = obj1 as List<dynamic>;
    final list2 = obj2 as List<dynamic>;

    if (list1.length != list2.length) {
      print('  리스트 길이 불일치: ${list1.length} vs ${list2.length}');
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (!_compareJson(list1[i], list2[i], depth: depth + 1)) {
        return false;
      }
    }
    return true;
  } else {
    return obj1 == obj2;
  }
}
