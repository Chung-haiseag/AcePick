import 'package:flutter_test/flutter_test.dart';
import 'package:acepick/core/data/mock_data_loader.dart';
import 'package:acepick/features/race/data/models/race_model.dart';

void main() {
  group('MockDataLoader Tests', () {
    test('loadRaces() - 경주 데이터 로드 성공', () async {
      final races = await MockDataLoader.loadRaces();

      expect(races, isNotEmpty);
      expect(races.length, greaterThan(0));
      expect(races[0], isA<RaceModel>());
    });

    test('loadRaces() - 로드된 경주 데이터 검증', () async {
      final races = await MockDataLoader.loadRaces();

      final race = races[0];
      expect(race.raceId, isNotNull);
      expect(race.track, isNotEmpty);
      expect(race.raceDate, isNotEmpty);
      expect(race.distance, greaterThan(0));
      expect(race.horses, isNotEmpty);
    });

    test('loadRaces() - 말 데이터 검증', () async {
      final races = await MockDataLoader.loadRaces();
      final horse = races[0].horses[0];

      expect(horse.horseName, isNotEmpty);
      expect(horse.jockey, isNotEmpty);
      expect(horse.trainer, isNotEmpty);
      expect(horse.odds, greaterThan(0));
      expect(horse.recentForm, isNotEmpty);
    });

    test('getTodayRaces() - 오늘 경주 필터링', () async {
      final todayRaces = await MockDataLoader.getTodayRaces();

      expect(todayRaces, isNotEmpty);
      for (var race in todayRaces) {
        expect(race.raceDate, isNotEmpty);
      }
    });

    test('데이터 일관성 - 같은 데이터 로드 시 동일한 결과', () async {
      final races1 = await MockDataLoader.loadRaces();
      final races2 = await MockDataLoader.loadRaces();

      expect(races1.length, races2.length);
      expect(races1[0].raceId, races2[0].raceId);
      expect(races1[0].track, races2[0].track);
    });

    test('loadTipsters() - 팁스터 데이터 로드 성공', () async {
      final tipsters = await MockDataLoader.loadTipsters();

      expect(tipsters, isNotEmpty);
      expect(tipsters.length, greaterThan(0));
    });

    test('경주 개수 검증', () async {
      final races = await MockDataLoader.loadRaces();

      expect(races.length, greaterThanOrEqualTo(10));
    });

    test('경주 번호 검증', () async {
      final races = await MockDataLoader.loadRaces();

      for (var race in races) {
        expect(race.raceNumber, greaterThanOrEqualTo(1));
        expect(race.raceNumber, lessThanOrEqualTo(12));
      }
    });

    test('경주 거리 검증', () async {
      final races = await MockDataLoader.loadRaces();

      for (var race in races) {
        expect(race.distance, greaterThan(0));
        expect(race.distance, lessThanOrEqualTo(3000));
      }
    });

    test('말 수 검증', () async {
      final races = await MockDataLoader.loadRaces();

      for (var race in races) {
        expect(race.horses.length, greaterThan(0));
        expect(race.horses.length, lessThanOrEqualTo(12));
      }
    });

    test('배당률 검증', () async {
      final races = await MockDataLoader.loadRaces();

      for (var race in races) {
        for (var horse in race.horses) {
          expect(horse.odds, greaterThan(0));
          expect(horse.odds, lessThan(100));
        }
      }
    });

    test('데이터 로드 스트레스 테스트', () async {
      for (int i = 0; i < 5; i++) {
        final races = await MockDataLoader.loadRaces();
        expect(races.isNotEmpty, true);
      }
    });
  });
}
