import 'dart:developer' as developer;
import 'lib/core/data/mock_data_loader.dart';

void main() async {
  print('=' * 100);
  print('🧪 MockDataLoader 테스트');
  print('=' * 100);
  print('');

  try {
    // 1. 경주 데이터 로드
    print('📖 경주 데이터 로드 중...');
    final races = await MockDataLoader.loadRaces();
    print('✓ 경주 데이터 로드 완료');
    print('  - 총 경주 수: ${races.length}');
    print('');

    // 2. 첫 3개 경주 출력
    print('=' * 100);
    print('📋 첫 3개 경주 정보');
    print('=' * 100);
    print('');

    for (int i = 0; i < (races.length > 3 ? 3 : races.length); i++) {
      final race = races[i];
      print('🏇 경주 #${i + 1}');
      print('  - ID: ${race.raceId}');
      print('  - 경주명: ${race.raceName}');
      print('  - 날짜: ${race.raceDate}');
      print('  - 시간: ${race.raceTime}');
      print('  - 경마장: ${race.track}');
      print('  - 거리: ${race.distance}m');
      print('  - 출전 말: ${race.horses.length}마리');
      print('  - 날씨: ${race.weather}');
      print('  - 마장 상태: ${race.trackCondition}');
      print('');
    }

    // 3. 첫 번째 경주의 말 정보 출력
    print('=' * 100);
    print('🐴 첫 번째 경주의 첫 3마리 말 정보');
    print('=' * 100);
    print('');

    if (races.isNotEmpty) {
      final firstRace = races[0];
      for (int i = 0; i < (firstRace.horses.length > 3 ? 3 : firstRace.horses.length); i++) {
        final horse = firstRace.horses[i];
        print('🐎 말 #${i + 1}');
        print('  - ID: ${horse.horseId}');
        print('  - 이름: ${horse.horseName}');
        print('  - 기수: ${horse.jockey}');
        print('  - 조교사: ${horse.trainer}');
        print('  - 게이트: ${horse.gate}');
        print('  - 배당: ${horse.odds}');
        print('  - 체중: ${horse.weight}kg');
        print('  - 최근 전적: ${horse.recentForm.join(', ')}');
        print('  - 부마: ${horse.pedigree.sire}');
        print('  - 모마: ${horse.pedigree.dam}');
        print('  - 구간 기록: ${horse.sectionalTimes.first600m}s + ${horse.sectionalTimes.second600m}s + ${horse.sectionalTimes.last600m}s');
        print('  - AI 예측: ${horse.aiPrediction.rank}위 (신뢰도: ${(horse.aiPrediction.confidence * 100).toStringAsFixed(1)}%)');
        print('');
      }
    }

    // 4. 팁스터 데이터 로드
    print('=' * 100);
    print('📖 팁스터 데이터 로드 중...');
    print('=' * 100);
    print('');

    final tipsters = await MockDataLoader.loadTipsters();
    print('✓ 팁스터 데이터 로드 완료');
    print('  - 총 팁스터 수: ${tipsters.length}명');
    print('');

    // 5. 상위 3명 팁스터 출력
    print('=' * 100);
    print('🏆 상위 3명 팁스터 정보');
    print('=' * 100);
    print('');

    final topTipsters = await MockDataLoader.getTopTipsters(limit: 3);
    for (int i = 0; i < topTipsters.length; i++) {
      final tipster = topTipsters[i];
      print('👤 팁스터 #${i + 1}');
      print('  - ID: ${tipster.tipsterId}');
      print('  - 이름: ${tipster.username}');
      print('  - 검증: ${tipster.verified ? '✓ 검증됨' : '✗ 미검증'}');
      print('  - 신뢰도 점수: ${tipster.trustIndex.score}');
      print('  - 정확도: ${(tipster.trustIndex.components.accuracy * 100).toStringAsFixed(1)}%');
      print('  - 일관성: ${(tipster.trustIndex.components.consistency * 100).toStringAsFixed(1)}%');
      print('  - 예측량: ${tipster.trustIndex.components.volume}');
      print('  - 투명성: ${(tipster.trustIndex.components.transparency * 100).toStringAsFixed(1)}%');
      print('  - Brier Score: ${tipster.trustIndex.brierScore}');
      print('  - ROI: ${tipster.trustIndex.roi}%');
      print('  - 총 예측: ${tipster.stats.totalPredictions}');
      print('  - 우승: ${tipster.stats.wins} (${tipster.stats.getWinRate().toStringAsFixed(1)}%)');
      print('  - 입상: ${tipster.stats.places} (${tipster.stats.getPlaceRate().toStringAsFixed(1)}%)');
      print('  - 팔로워: ${tipster.stats.totalFollowers}명');
      print('');
    }

    // 6. 캐시 상태 확인
    print('=' * 100);
    print('💾 캐시 상태');
    print('=' * 100);
    print('');
    print(MockDataLoader.getCacheStatus());
    print('');

    // 7. 캐시 테스트 (두 번째 로드는 캐시에서 가져옴)
    print('=' * 100);
    print('🔄 캐시 테스트 (두 번째 로드)');
    print('=' * 100);
    print('');

    print('📖 경주 데이터 다시 로드 중... (캐시에서 가져옴)');
    final races2 = await MockDataLoader.loadRaces();
    print('✓ 경주 데이터 로드 완료 (캐시)');
    print('  - 총 경주 수: ${races2.length}');
    print('  - 동일한 데이터: ${races == races2}');
    print('');

    // 8. 필터링 테스트
    print('=' * 100);
    print('🔍 필터링 테스트');
    print('=' * 100);
    print('');

    print('📅 오늘 경주 필터링:');
    final todayRaces = await MockDataLoader.getTodayRaces();
    print('  - 오늘 경주: ${todayRaces.length}개');
    print('');

    print('📅 향후 7일 경주 필터링:');
    final upcomingRaces = await MockDataLoader.getUpcomingRaces(7);
    print('  - 향후 7일 경주: ${upcomingRaces.length}개');
    print('');

    print('✓ 검증된 팁스터 필터링:');
    final verifiedTipsters = await MockDataLoader.getVerifiedTipsters();
    print('  - 검증된 팁스터: ${verifiedTipsters.length}명');
    print('');

    print('📊 신뢰도 80 이상 팁스터:');
    final highScoreTipsters = await MockDataLoader.getTipstersByMinScore(minScore: 80.0);
    print('  - 신뢰도 80 이상: ${highScoreTipsters.length}명');
    print('');

    // 9. 최종 요약
    print('=' * 100);
    print('✅ 테스트 완료');
    print('=' * 100);
    print('');
    print('📊 요약:');
    print('  - 총 경주: ${races.length}개');
    print('  - 총 팁스터: ${tipsters.length}명');
    print('  - 상위 팁스터 (신뢰도): ${topTipsters[0].username} (${topTipsters[0].trustIndex.score})');
    print('  - 캐시 상태: ${MockDataLoader.getCacheStatus()}');
    print('');
    print('🎉 모든 테스트가 성공적으로 완료되었습니다!');
    print('');

  } catch (e) {
    print('❌ 에러 발생: $e');
    print('$e');
  }
}
