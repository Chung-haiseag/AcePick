import 'package:flutter/material.dart';
import 'package:acepick/features/race/data/models/race_model.dart';
import 'package:acepick/features/race/presentation/screens/race_detail_screen.dart';

/// 경주 검색 기능을 제공하는 SearchDelegate
///
/// 경주 ID, 트랙명으로 검색하고 결과를 표시합니다.
class RaceSearchDelegate extends SearchDelegate<RaceModel?> {
  /// 검색할 경주 목록
  final List<RaceModel> races;

  RaceSearchDelegate({required this.races});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      // 검색어 지우기 버튼
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // 검색 결과 필터링
    final results = _filterRaces(query);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과 없음',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '"$query"에 대한 경주를 찾을 수 없습니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final race = results[index];
        return _buildRaceSearchResultCard(context, race);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // 검색 제안 (검색어가 없을 때는 최근 경주 표시)
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '경주를 검색하세요',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '경주 ID 또는 경마장명으로 검색할 수 있습니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // 검색 제안 필터링
    final suggestions = _filterRaces(query);

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final race = suggestions[index];
        return _buildRaceSearchSuggestionCard(context, race);
      },
    );
  }

  /// 경주 목록을 검색어로 필터링합니다
  List<RaceModel> _filterRaces(String query) {
    if (query.isEmpty) {
      return races;
    }

    final lowerQuery = query.toLowerCase();
    return races.where((race) {
      // 경주 ID로 검색
      final matchesId = race.raceId.toLowerCase().contains(lowerQuery);
      // 트랙명으로 검색
      final matchesTrack = race.track.toLowerCase().contains(lowerQuery);
      // 경주명으로 검색
      final matchesName = race.raceName.toLowerCase().contains(lowerQuery);
      // 경주 번호로 검색
      final matchesNumber = race.raceNumber.toString().contains(lowerQuery);

      return matchesId || matchesTrack || matchesName || matchesNumber;
    }).toList();
  }

  /// 검색 결과 카드를 빌드합니다
  Widget _buildRaceSearchResultCard(BuildContext context, RaceModel race) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        // 경주 번호를 표시하는 원형 아바타
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: Text(
            '${race.raceNumber}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        // 경마장과 경주 번호
        title: Text(
          '${race.track} ${race.raceNumber}경주',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        // 거리와 날짜
        subtitle: Text(
          '${race.distance}m · ${race.raceDate}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        // 출전 말 수
        trailing: Text(
          '${race.horses.length}두',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        // 탭 이벤트
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RaceDetailScreen(race: race),
            ),
          );
        },
      ),
    );
  }

  /// 검색 제안 카드를 빌드합니다
  Widget _buildRaceSearchSuggestionCard(BuildContext context, RaceModel race) {
    return ListTile(
      // 검색 아이콘
      leading: const Icon(Icons.history),
      // 경주 정보
      title: Text('${race.track} ${race.raceNumber}경주'),
      subtitle: Text(race.raceDate),
      // 탭 이벤트
      onTap: () {
        query = '${race.track} ${race.raceNumber}경주';
        showResults(context);
      },
    );
  }
}
