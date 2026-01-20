import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:acepick/features/race/data/models/race_model.dart';
import 'package:acepick/features/tipster/data/models/tipster_model.dart';

/// Mock 데이터를 로드하고 필터링하는 유틸리티 클래스
///
/// assets/mock_data 폴더의 JSON 파일들을 로드하여 모델 객체로 변환합니다.
/// 또한 날짜, 신뢰도 등의 기준으로 데이터를 필터링하는 기능을 제공합니다.
class MockDataLoader {
  // 싱글톤 인스턴스
  static final MockDataLoader _instance = MockDataLoader._internal();

  // 캐시된 데이터
  static List<RaceModel>? _cachedRaces;
  static List<TipsterModel>? _cachedTipsters;

  MockDataLoader._internal();

  /// MockDataLoader 싱글톤 인스턴스 반환
  factory MockDataLoader() {
    return _instance;
  }

  /// 모든 경주 데이터를 로드합니다
  ///
  /// assets/mock_data/races.json 파일을 읽어 RaceModel 리스트로 변환합니다.
  /// 데이터는 메모리에 캐시되어 이후 호출 시 캐시된 데이터를 반환합니다.
  ///
  /// 반환: RaceModel 리스트 (파일이 없거나 에러 발생 시 빈 리스트)
  static Future<List<RaceModel>> loadRaces() async {
    try {
      // 캐시된 데이터가 있으면 반환
      if (_cachedRaces != null) {
        developer.log('🔄 캐시된 경주 데이터 반환 (${_cachedRaces!.length}개)');
        return _cachedRaces!;
      }

      developer.log('📖 races.json 파일 로드 중...');
      final jsonString = await rootBundle.loadString('assets/mock_data/races.json');
      
      final jsonData = jsonDecode(jsonString) as List<dynamic>;
      _cachedRaces = jsonData
          .map((race) => RaceModel.fromJson(race as Map<String, dynamic>))
          .toList();

      developer.log('✓ 경주 데이터 로드 완료 (${_cachedRaces!.length}개)');
      return _cachedRaces!;
    } catch (e) {
      developer.log('❌ 경주 데이터 로드 실패: $e', error: e);
      return [];
    }
  }

  /// 오늘 날짜의 경주만 필터링하여 반환합니다
  ///
  /// 현재 날짜(DateTime.now())와 일치하는 경주만 반환합니다.
  ///
  /// 반환: 오늘 경주의 RaceModel 리스트
  static Future<List<RaceModel>> getTodayRaces() async {
    try {
      final races = await loadRaces();
      final today = DateTime.now();
      final todayString = '${today.year.toString().padLeft(4, '0')}-'
          '${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';

      final todayRaces = races
          .where((race) => race.raceDate == todayString)
          .toList();

      developer.log('📅 오늘 경주 필터링 완료 (${todayRaces.length}개)');
      return todayRaces;
    } catch (e) {
      developer.log('❌ 오늘 경주 필터링 실패: $e', error: e);
      return [];
    }
  }

  /// 오늘부터 N일 이내의 경주를 필터링하여 반환합니다
  ///
  /// [days] 기간 (일 단위)
  /// 반환: 해당 기간 내의 RaceModel 리스트
  static Future<List<RaceModel>> getUpcomingRaces(int days) async {
    try {
      final races = await loadRaces();
      final today = DateTime.now();
      final endDate = today.add(Duration(days: days));

      final upcomingRaces = races.where((race) {
        final raceDate = DateTime.parse(race.raceDate);
        return raceDate.isAfter(today) && raceDate.isBefore(endDate);
      }).toList();

      developer.log('📅 향후 $days일 경주 필터링 완료 (${upcomingRaces.length}개)');
      return upcomingRaces;
    } catch (e) {
      developer.log('❌ 향후 경주 필터링 실패: $e', error: e);
      return [];
    }
  }

  /// 특정 날짜의 경주를 필터링하여 반환합니다
  ///
  /// [date] 조회할 날짜
  /// 반환: 해당 날짜의 RaceModel 리스트
  static Future<List<RaceModel>> getRacesByDate(DateTime date) async {
    try {
      final races = await loadRaces();
      final dateString = '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      final racesByDate = races
          .where((race) => race.raceDate == dateString)
          .toList();

      developer.log('📅 $dateString 경주 필터링 완료 (${racesByDate.length}개)');
      return racesByDate;
    } catch (e) {
      developer.log('❌ 날짜별 경주 필터링 실패: $e', error: e);
      return [];
    }
  }

  /// 모든 팁스터 데이터를 로드합니다
  ///
  /// assets/mock_data/tipsters.json 파일을 읽어 TipsterModel 리스트로 변환합니다.
  /// 데이터는 메모리에 캐시되어 이후 호출 시 캐시된 데이터를 반환합니다.
  ///
  /// 반환: TipsterModel 리스트 (파일이 없거나 에러 발생 시 빈 리스트)
  static Future<List<TipsterModel>> loadTipsters() async {
    try {
      // 캐시된 데이터가 있으면 반환
      if (_cachedTipsters != null) {
        developer.log('🔄 캐시된 팁스터 데이터 반환 (${_cachedTipsters!.length}명)');
        return _cachedTipsters!;
      }

      developer.log('📖 tipsters.json 파일 로드 중...');
      final jsonString = await rootBundle.loadString('assets/mock_data/tipsters.json');
      
      final jsonData = jsonDecode(jsonString) as List<dynamic>;
      _cachedTipsters = jsonData
          .map((tipster) => TipsterModel.fromJson(tipster as Map<String, dynamic>))
          .toList();

      developer.log('✓ 팁스터 데이터 로드 완료 (${_cachedTipsters!.length}명)');
      return _cachedTipsters!;
    } catch (e) {
      developer.log('❌ 팁스터 데이터 로드 실패: $e', error: e);
      return [];
    }
  }

  /// 신뢰도 지수 상위 N명의 팁스터를 반환합니다
  ///
  /// [limit] 반환할 팁스터 수 (기본값: 10)
  /// 반환: 신뢰도 상위 N명의 TipsterModel 리스트
  static Future<List<TipsterModel>> getTopTipsters({int limit = 10}) async {
    try {
      final tipsters = await loadTipsters();
      
      // 신뢰도 점수로 정렬 (내림차순)
      tipsters.sort((a, b) => b.trustIndex.score.compareTo(a.trustIndex.score));
      
      // 상위 limit개만 반환
      final topTipsters = tipsters.take(limit).toList();
      
      developer.log('🏆 상위 $limit명 팁스터 필터링 완료');
      return topTipsters;
    } catch (e) {
      developer.log('❌ 상위 팁스터 필터링 실패: $e', error: e);
      return [];
    }
  }

  /// 검증된 팁스터만 필터링하여 반환합니다
  ///
  /// 반환: 검증된(verified=true) TipsterModel 리스트
  static Future<List<TipsterModel>> getVerifiedTipsters() async {
    try {
      final tipsters = await loadTipsters();
      final verifiedTipsters = tipsters
          .where((tipster) => tipster.verified)
          .toList();

      developer.log('✓ 검증된 팁스터 필터링 완료 (${verifiedTipsters.length}명)');
      return verifiedTipsters;
    } catch (e) {
      developer.log('❌ 검증된 팁스터 필터링 실패: $e', error: e);
      return [];
    }
  }

  /// 특정 신뢰도 점수 이상의 팁스터를 필터링하여 반환합니다
  ///
  /// [minScore] 최소 신뢰도 점수 (기본값: 80.0)
  /// 반환: 신뢰도 점수가 minScore 이상인 TipsterModel 리스트
  static Future<List<TipsterModel>> getTipstersByMinScore({double minScore = 80.0}) async {
    try {
      final tipsters = await loadTipsters();
      final filteredTipsters = tipsters
          .where((tipster) => tipster.trustIndex.score >= minScore)
          .toList();

      developer.log('📊 신뢰도 $minScore 이상 팁스터 필터링 완료 (${filteredTipsters.length}명)');
      return filteredTipsters;
    } catch (e) {
      developer.log('❌ 신뢰도 필터링 실패: $e', error: e);
      return [];
    }
  }

  /// 캐시된 데이터를 초기화합니다
  ///
  /// 메모리에 캐시된 모든 데이터를 삭제합니다.
  /// 다시 로드 시 파일에서 새로 읽어옵니다.
  static void clearCache() {
    _cachedRaces = null;
    _cachedTipsters = null;
    developer.log('🗑️ 캐시 초기화 완료');
  }

  /// 캐시 상태를 반환합니다
  ///
  /// 반환: 캐시된 경주 수와 팁스터 수를 포함한 문자열
  static String getCacheStatus() {
    final raceCount = _cachedRaces?.length ?? 0;
    final tipsterCount = _cachedTipsters?.length ?? 0;
    return 'Cache Status: Races=$raceCount, Tipsters=$tipsterCount';
  }
}
