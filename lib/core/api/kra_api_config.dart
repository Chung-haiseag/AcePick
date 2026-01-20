import 'package:flutter_dotenv/flutter_dotenv.dart';

class KraApiConfig {
  // Base URL
  static String get BASE_URL => 
      dotenv.env['KRA_BASE_URL'] ?? 'https://apis.data.go.kr/B551015/API214_1';
  
  // Service Key
  static String get SERVICE_KEY => 
      dotenv.env['KRA_API_KEY'] ?? '';
  
  // Timeout
  static const Duration TIMEOUT = Duration(seconds: 30);
  
  // Endpoints
  static const String RACE_RESULT = '/RaceDetailResult_1';
  
  // 경주장 코드 (meet 파라미터)
  static const Map<String, String> MEET_CODES = {
    '서울': '1',
    '제주': '2',
    '부산경남': '3',
  };
  
  // 역 매핑
  static String getMeetName(String code) {
    return MEET_CODES.entries
        .firstWhere(
          (e) => e.value == code, 
          orElse: () => MapEntry('알 수 없음', code)
        )
        .key;
  }
  
  // 전체 URL 생성
  static String buildUrl({
    required String endpoint,
    required Map<String, String> params,
  }) {
    final uri = Uri.parse('$BASE_URL$endpoint');
    final queryParams = {
      'ServiceKey': SERVICE_KEY,
      '_type': 'json',
      ...params,
    };
    return uri.replace(queryParameters: queryParams).toString();
  }
}
