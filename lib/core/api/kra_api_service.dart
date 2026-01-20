import 'package:http/http.dart' as http;
import 'dart:convert';
import 'kra_api_config.dart';
import '../../features/race/data/models/kra/kra_race_result_response.dart';

class KraApiService {
  static final KraApiService _instance = KraApiService._internal();
  factory KraApiService() => _instance;
  KraApiService._internal();

  /// 경주 결과 조회
  /// 
  /// [meet] - 경마장 코드 (1:서울, 2:제주, 3:부산경남)
  /// [rcDate] - 경주일자 (YYYYMMDD)
  /// [rcNo] - 경주번호
  /// [numOfRows] - 한 페이지 결과 수 (기본 10)
  /// [pageNo] - 페이지 번호 (기본 1)
  Future<KraRaceResultResponse> getRaceResult({
    String? meet,
    String? rcDate,
    String? rcNo,
    String? rcYear,
    String? rcMonth,
    int numOfRows = 10,
    int pageNo = 1,
  }) async {
    try {
      // 파라미터 구성
      final params = {
        'numOfRows': numOfRows.toString(),
        'pageNo': pageNo.toString(),
      };

      if (meet != null) params['meet'] = meet;
      if (rcDate != null) params['rc_date'] = rcDate;
      if (rcNo != null) params['rc_no'] = rcNo;
      if (rcYear != null) params['rc_year'] = rcYear;
      if (rcMonth != null) params['rc_month'] = rcMonth;

      // URL 생성
      final url = KraApiConfig.buildUrl(
        endpoint: KraApiConfig.RACE_RESULT,
        params: params,
      );

      print('🔍 KRA API Request: $url');
      final stopwatch = Stopwatch()..start();

      // HTTP 요청
      final response = await http
          .get(Uri.parse(url))
          .timeout(KraApiConfig.TIMEOUT);

      stopwatch.stop();
      print('⏱️  Response time: ${stopwatch.elapsedMilliseconds}ms');
      print('📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // JSON 파싱
        final jsonData = jsonDecode(response.body);
        final kraResponse = KraRaceResultResponse.fromJson(jsonData);

        // API 응답 코드 확인
        if (!kraResponse.header.isSuccess) {
          throw KraApiException(
            code: kraResponse.header.resultCode,
            message: kraResponse.header.resultMsg,
          );
        }

        print('✅ Success: ${kraResponse.body.totalCount} items');
        return kraResponse;
      } else {
        throw KraApiException(
          code: 'HTTP_${response.statusCode}',
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } on KraApiException {
      rethrow;
    } catch (e) {
      print('❌ KRA API Error: $e');
      throw KraApiException(
        code: 'UNKNOWN',
        message: e.toString(),
      );
    }
  }

  /// 특정 날짜의 모든 경주 조회
  Future<List<KraRaceItem>> getAllRacesForDate(String date) async {
    final List<KraRaceItem> allRaces = [];

    // 3개 경마장 반복
    for (var meetEntry in KraApiConfig.MEET_CODES.entries) {
      final meetCode = meetEntry.value;
      print('📍 Fetching ${meetEntry.key} races for $date');

      try {
        // 해당 경마장의 모든 경주 조회 (최대 12경주)
        final response = await getRaceResult(
          meet: meetCode,
          rcDate: date,
          numOfRows: 100, // 한 번에 많이 가져오기
        );

        allRaces.addAll(response.body.items);
      } catch (e) {
        print('⚠️  No races for ${meetEntry.key} on $date');
        continue;
      }
    }

    return allRaces;
  }

  /// 특정 월의 모든 경주 조회
  Future<List<KraRaceItem>> getAllRacesForMonth(String yearMonth) async {
    final List<KraRaceItem> allRaces = [];

    for (var meetEntry in KraApiConfig.MEET_CODES.entries) {
      final meetCode = meetEntry.value;
      
      try {
        final response = await getRaceResult(
          meet: meetCode,
          rcMonth: yearMonth,
          numOfRows: 100,
        );

        allRaces.addAll(response.body.items);
      } catch (e) {
        print('⚠️  No races for ${meetEntry.key} in $yearMonth');
        continue;
      }
    }

    return allRaces;
  }
}

/// KRA API 예외 클래스
class KraApiException implements Exception {
  final String code;
  final String message;

  KraApiException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'KraApiException($code): $message';

  /// 사용자 친화적 메시지
  String get userMessage {
    switch (code) {
      case '1':
        return '서비스 오류가 발생했습니다.';
      case '10':
        return '잘못된 요청입니다.';
      case '12':
        return '해당 서비스를 사용할 수 없습니다.';
      case '20':
        return '서비스 접근이 거부되었습니다.';
      case '22':
        return '일일 요청 한도를 초과했습니다.';
      case '30':
        return '인증키가 유효하지 않습니다.';
      case '31':
        return '인증키 사용 기한이 만료되었습니다.';
      case '32':
        return '등록되지 않은 IP입니다.';
      default:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }
}
