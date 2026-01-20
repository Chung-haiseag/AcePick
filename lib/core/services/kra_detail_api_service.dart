// lib/core/services/kra_detail_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/result/data/models/race_result_model.dart';

class KraDetailApiService {
  static final KraDetailApiService _instance = KraDetailApiService._internal();
  factory KraDetailApiService() => _instance;
  KraDetailApiService._internal();

  static String get baseUrl => 'https://apis.data.go.kr/B551015';
  static String get serviceKey => dotenv.env['API_KEY'] ?? '';
  
  // API214_1: 경주성적 상세정보
  static const String raceDetailResultEndpoint = '/API214_1/RaceDetailResult_1';
  
  // API4_3: 경주기록 정보
  static const String raceResultEndpoint = '/API4_3/raceResult_3';

  /// 경주성적 상세정보 조회 (API214_1)
  Future<List<RaceResult>> getRaceDetailResults({
    required String rcDate,
    String? meet,
    String? rcNo,
    int numOfRows = 20,
    int pageNo = 1,
  }) async {
    final queryParams = {
      'ServiceKey': serviceKey,
      'numOfRows': numOfRows.toString(),
      'pageNo': pageNo.toString(),
      'rc_date': rcDate,
      if (meet != null) 'meet': meet,
      if (rcNo != null) 'rc_no': rcNo,
      '_type': 'json', // JSON 응답 요청
    };

    final uri = Uri.parse('$baseUrl$raceDetailResultEndpoint')
        .replace(queryParameters: queryParams);

    try {
      print('🔍 KRA Detail API Request: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // 응답 구조 확인
        if (jsonData['response']['header']['resultCode'] == '00') {
          final items = jsonData['response']['body']['items']['item'];
          
          // items가 단일 객체인 경우 리스트로 변환
          final itemList = items is List ? items : [items];
          
          // 경주별로 그룹화
          final Map<String, List<dynamic>> groupedByRace = {};
          for (var item in itemList) {
            final raceKey = '${item['rcDate']}_${item['rcNo']}';
            groupedByRace.putIfAbsent(raceKey, () => []);
            groupedByRace[raceKey]!.add(item);
          }
          
          // RaceResult 객체 생성
          return groupedByRace.entries.map((entry) {
            final raceItems = entry.value;
            final firstItem = raceItems.first;
            
            return RaceResult(
              raceId: entry.key,
              raceName: firstItem['rcName'] ?? '일반',
              raceDate: DateTime.parse(firstItem['rcDate']),
              track: _getTrackName(firstItem['meet']),
              distance: int.parse(firstItem['rcDist'].toString()),
              grade: firstItem['rank'] ?? '일반',
              results: raceItems.map((item) {
                return HorseResult(
                  rank: int.parse(item['ord'].toString()),
                  horseName: item['hrName'] ?? '',
                  horseNumber: int.parse(item['chulNo'].toString()),
                  jockeyName: item['jkName'] ?? '',
                  trainerName: item['trName'] ?? '',
                  weight: double.parse(
                      item['wgHr'].toString().replaceAll(RegExp(r'[^0-9.]'), '')),
                  recordTime: item['rcTime']?.toString() ?? '0',
                  odds: double.parse(item['winOdds']?.toString() ?? '0'),
                );
              }).toList()
                ..sort((a, b) => a.rank.compareTo(b.rank)),
              dividends: {
                '단승': double.parse(
                    raceItems.first['winOdds']?.toString() ?? '0'),
                '복승': double.parse(
                    raceItems.first['plcOdds']?.toString() ?? '0'),
              },
            );
          }).toList();
        } else {
          print('⚠️  API Error: ${jsonData['response']['header']['resultMsg']}');
          return [];
        }
      }
      
      print('❌ HTTP Error: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Exception: $e');
      return [];
    }
  }

  /// 최근 한 달간 경기 결과 조회
  Future<List<RaceResult>> getRecentMonthResults({
    String? track,
    int numOfRows = 20,
    int pageNo = 1,
  }) async {
    final now = DateTime.now();
    final List<RaceResult> allResults = [];
    
    // 최근 30일간 날짜별로 조회
    for (int i = 0; i < 30; i++) {
      final targetDate = now.subtract(Duration(days: i));
      final dateString = 
          '${targetDate.year}${targetDate.month.toString().padLeft(2, '0')}${targetDate.day.toString().padLeft(2, '0')}';
      
      try {
        final results = await getRaceDetailResults(
          rcDate: dateString,
          meet: track,
          numOfRows: numOfRows,
          pageNo: pageNo,
        );
        
        allResults.addAll(results);
      } catch (e) {
        // 해당 날짜에 경주가 없을 수 있으므로 에러 무시
        continue;
      }
    }
    
    // 날짜순 정렬
    allResults.sort((a, b) => b.raceDate.compareTo(a.raceDate));
    
    return allResults;
  }

  /// 특정 경마장의 특정 월 경주 결과 조회
  Future<List<RaceResult>> getMonthlyResults({
    required String rcMonth, // YYYYMM 형식
    String? meet,
    int numOfRows = 100,
  }) async {
    final queryParams = {
      'ServiceKey': serviceKey,
      'numOfRows': numOfRows.toString(),
      'pageNo': '1',
      'rc_month': rcMonth,
      if (meet != null) 'meet': meet,
      '_type': 'json',
    };

    final uri = Uri.parse('$baseUrl$raceDetailResultEndpoint')
        .replace(queryParameters: queryParams);

    try {
      print('🔍 KRA Monthly API Request: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['response']['header']['resultCode'] == '00') {
          final items = jsonData['response']['body']['items']['item'];
          
          // items가 단일 객체인 경우 리스트로 변환
          final itemList = items is List ? items : [items];
          
          // 경주별로 그룹화하여 RaceResult 생성
          final Map<String, List<dynamic>> groupedByRace = {};
          for (var item in itemList) {
            final raceKey = '${item['rcDate']}_${item['rcNo']}';
            groupedByRace.putIfAbsent(raceKey, () => []);
            groupedByRace[raceKey]!.add(item);
          }
          
          return groupedByRace.entries.map((entry) {
            final raceItems = entry.value;
            final firstItem = raceItems.first;
            
            return RaceResult(
              raceId: entry.key,
              raceName: firstItem['rcName'] ?? '일반',
              raceDate: DateTime.parse(firstItem['rcDate']),
              track: _getTrackName(firstItem['meet']),
              distance: int.parse(firstItem['rcDist'].toString()),
              grade: firstItem['rank'] ?? '일반',
              results: raceItems.map((item) {
                return HorseResult(
                  rank: int.parse(item['ord'].toString()),
                  horseName: item['hrName'] ?? '',
                  horseNumber: int.parse(item['chulNo'].toString()),
                  jockeyName: item['jkName'] ?? '',
                  trainerName: item['trName'] ?? '',
                  weight: double.parse(
                      item['wgHr'].toString().replaceAll(RegExp(r'[^0-9.]'), '')),
                  recordTime: item['rcTime']?.toString() ?? '0',
                  odds: double.parse(item['winOdds']?.toString() ?? '0'),
                );
              }).toList()
                ..sort((a, b) => a.rank.compareTo(b.rank)),
              dividends: {
                '1착': double.parse(
                    firstItem['chaksun1']?.toString() ?? '0'),
                '2착': double.parse(
                    firstItem['chaksun2']?.toString() ?? '0'),
                '3착': double.parse(
                    firstItem['chaksun3']?.toString() ?? '0'),
                '단승': double.parse(
                    raceItems.first['winOdds']?.toString() ?? '0'),
                '복승': double.parse(
                    raceItems.first['plcOdds']?.toString() ?? '0'),
              },
            );
          }).toList()
            ..sort((a, b) => b.raceDate.compareTo(a.raceDate));
        } else {
          print('⚠️  API Error: ${jsonData['response']['header']['resultMsg']}');
          return [];
        }
      }
      
      print('❌ HTTP Error: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Exception: $e');
      return [];
    }
  }

  /// 경마장 코드를 이름으로 변환
  String _getTrackName(String? code) {
    switch (code) {
      case '1':
        return '서울';
      case '2':
        return '제주';
      case '3':
        return '부산경남';
      default:
        return code ?? '알 수 없음';
    }
  }
}
