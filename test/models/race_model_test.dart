import 'package:flutter_test/flutter_test.dart';
import 'package:acepick/features/race/data/models/race_model.dart';

void main() {
  group('RaceModel Tests', () {
    test('RaceModel 생성 - 정상 생성', () {
      final race = RaceModel(
        raceId: 'R20260131_01',
        raceDate: '2026-01-31',
        raceNumber: 1,
        raceName: '01월 31일 1경주',
        raceTime: '10:00',
        track: '서울경마장',
        distance: 1800,
        horses: [],
        weather: '맑음',
        trackCondition: '양호',
        createdAt: '2026-01-20T10:00:00Z',
      );

      expect(race.raceId, 'R20260131_01');
      expect(race.track, '서울경마장');
      expect(race.raceDate, '2026-01-31');
      expect(race.distance, 1800);
      expect(race.horses.length, 0);
    });

    test('RaceModel 필드 검증', () {
      final race = RaceModel(
        raceId: 'R20260131_02',
        raceDate: '2026-01-31',
        raceNumber: 2,
        raceName: '01월 31일 2경주',
        raceTime: '10:30',
        track: '부산경마장',
        distance: 2000,
        horses: [],
        weather: '흐림',
        trackCondition: '보통',
        createdAt: '2026-01-20T10:00:00Z',
      );

      expect(race.raceNumber, 2);
      expect(race.raceName, '01월 31일 2경주');
      expect(race.raceTime, '10:30');
      expect(race.weather, '흐림');
      expect(race.trackCondition, '보통');
    });

    test('RaceModel 필드 비교', () {
      final race1 = RaceModel(
        raceId: 'R20260131_01',
        raceDate: '2026-01-31',
        raceNumber: 1,
        raceName: '01월 31일 1경주',
        raceTime: '10:00',
        track: '서울경마장',
        distance: 1800,
        horses: [],
        weather: '맑음',
        trackCondition: '양호',
        createdAt: '2026-01-20T10:00:00Z',
      );

      final race2 = RaceModel(
        raceId: 'R20260131_01',
        raceDate: '2026-01-31',
        raceNumber: 1,
        raceName: '01월 31일 1경주',
        raceTime: '10:00',
        track: '서울경마장',
        distance: 1800,
        horses: [],
        weather: '맑음',
        trackCondition: '양호',
        createdAt: '2026-01-20T10:00:00Z',
      );

      expect(race1.raceId, race2.raceId);
      expect(race1.track, race2.track);
      expect(race1.distance, race2.distance);
    });

    test('RaceModel 다른 값 비교', () {
      final race1 = RaceModel(
        raceId: 'R20260131_01',
        raceDate: '2026-01-31',
        raceNumber: 1,
        raceName: '01월 31일 1경주',
        raceTime: '10:00',
        track: '서울경마장',
        distance: 1800,
        horses: [],
        weather: '맑음',
        trackCondition: '양호',
        createdAt: '2026-01-20T10:00:00Z',
      );

      final race2 = RaceModel(
        raceId: 'R20260131_02',
        raceDate: '2026-01-31',
        raceNumber: 2,
        raceName: '01월 31일 2경주',
        raceTime: '10:30',
        track: '부산경마장',
        distance: 2000,
        horses: [],
        weather: '흐림',
        trackCondition: '보통',
        createdAt: '2026-01-20T10:00:00Z',
      );

      expect(race1.raceId != race2.raceId, true);
      expect(race1.track != race2.track, true);
    });

    test('RaceModel toString', () {
      final race = RaceModel(
        raceId: 'R20260131_01',
        raceDate: '2026-01-31',
        raceNumber: 1,
        raceName: '01월 31일 1경주',
        raceTime: '10:00',
        track: '서울경마장',
        distance: 1800,
        horses: [],
        weather: '맑음',
        trackCondition: '양호',
        createdAt: '2026-01-20T10:00:00Z',
      );

      final str = race.toString();

      expect(str.contains('RaceModel'), true);
      expect(str.contains('01월 31일 1경주'), true);
      expect(str.contains('서울경마장'), true);
    });

    test('RaceModel 거리 검증', () {
      final distances = [1200, 1400, 1600, 1800, 2000, 2400];

      for (var distance in distances) {
        final race = RaceModel(
          raceId: 'R20260131_01',
          raceDate: '2026-01-31',
          raceNumber: 1,
          raceName: '01월 31일 1경주',
          raceTime: '10:00',
          track: '서울경마장',
          distance: distance,
          horses: [],
          weather: '맑음',
          trackCondition: '양호',
          createdAt: '2026-01-20T10:00:00Z',
        );
        expect(race.distance, distance);
      }
    });

    test('RaceModel 트랙 검증', () {
      final tracks = ['서울경마장', '부산경마장', '제주경마장'];

      for (var track in tracks) {
        final race = RaceModel(
          raceId: 'R20260131_01',
          raceDate: '2026-01-31',
          raceNumber: 1,
          raceName: '01월 31일 1경주',
          raceTime: '10:00',
          track: track,
          distance: 1800,
          horses: [],
          weather: '맑음',
          trackCondition: '양호',
          createdAt: '2026-01-20T10:00:00Z',
        );
        expect(race.track, track);
      }
    });
  });
}
