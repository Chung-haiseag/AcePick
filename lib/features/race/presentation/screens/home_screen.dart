import 'package:flutter/material.dart';
import 'package:acepick/core/data/mock_data_loader.dart';
import 'package:acepick/core/widgets/legal_disclaimer_banner.dart';
import 'package:acepick/features/race/data/models/race_model.dart';
import 'package:acepick/features/race/presentation/screens/race_detail_screen.dart';
import '../widgets/race_search_delegate.dart';
import 'ai_accuracy_screen.dart';
import 'package:acepick/features/tipster/presentation/screens/tipster_list_screen.dart';
import 'package:acepick/features/portfolio/presentation/screens/portfolio_screen.dart';

/// AcePick 메인 화면
///
/// BottomNavigationBar를 통해 홈, 팁스터, 포트폴리오 3개 탭을 제공합니다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// 현재 선택된 탭 인덱스
  int _currentTabIndex = 0;

  /// 경주 목록
  List<RaceModel> races = [];

  /// 필터링된 경주 목록
  List<RaceModel> filteredRaces = [];

  /// 로딩 상태
  bool isLoading = true;

  /// 에러 메시지
  String? errorMessage;

  /// 필터 상태
  String? selectedTrack;
  RangeValues distanceRange = const RangeValues(1000, 2000);
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadRaces();
  }

  /// 경주 데이터를 로드합니다
  Future<void> _loadRaces() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // MockDataLoader에서 경주 데이터 로드
      final loadedRaces = await MockDataLoader.loadRaces();

      // 최대 20개만 표시
      final limitedRaces = loadedRaces.take(20).toList();

      setState(() {
        races = limitedRaces;
        filteredRaces = limitedRaces;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '경주 데이터를 로드하는 중 오류가 발생했습니다: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AcePick - AI 경마 예측'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
        actions: [
          // 필터 버튼
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          // 검색 버튼
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RaceSearchDelegate(races: filteredRaces),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '팁스터',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: '포트폴리오',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.analytics),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AiAccuracyScreen()),
          );
        },
        tooltip: 'AI 예측 정확도',
      ),
    );
  }

  /// 현재 탭에 맞는 화면을 빌드합니다
  Widget _buildBody() {
    switch (_currentTabIndex) {
      case 0:
        // 홈 탭
        return Column(
          children: [
            // 법적 면책 배너
            LegalDisclaimerBanner(),
            // 경주 목록
            Expanded(
              child: _buildRaceList(filteredRaces),
            ),
          ],
        );
      case 1:
        // 팁스터 탭
        return const TipsterListScreen();
      case 2:
        // 포트폴리오 탭
        return const PortfolioScreen();
      default:
        return const SizedBox();
    }
  }

  /// 필터 BottomSheet를 표시합니다
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(),
      isScrollControlled: true,
    );
  }

  /// 필터 BottomSheet를 빌드합니다
  Widget _buildFilterBottomSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) => Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                '경주 필터',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // 트랙 선택
              Text(
                '트랙 선택',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['전체', '서울', '부산경남', '제주']
                    .map((track) => FilterChip(
                      label: Text(track),
                      selected: selectedTrack == track || (track == '전체' && selectedTrack == null),
                      onSelected: (selected) {
                        setModalState(() {
                          selectedTrack = track == '전체' ? null : track;
                        });
                      },
                    ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // 거리 범위 선택
              Text(
                '거리 범위 (${distanceRange.start.toInt()}m ~ ${distanceRange.end.toInt()}m)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: distanceRange,
                min: 1000,
                max: 2000,
                divisions: 10,
                labels: RangeLabels(
                  '${distanceRange.start.toInt()}m',
                  '${distanceRange.end.toInt()}m',
                ),
                onChanged: (RangeValues values) {
                  setModalState(() {
                    distanceRange = values;
                  });
                },
              ),
              const SizedBox(height: 24),

              // 날짜 선택
              Text(
                '날짜 선택',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2026),
                    lastDate: DateTime(2026, 12, 31),
                  );
                  if (picked != null) {
                    setModalState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(
                        selectedDate != null
                            ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                            : '날짜 선택',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 필터 적용 버튼
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text('필터 적용'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _resetFilters();
                        setModalState(() {});
                      },
                      child: const Text('초기화'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 필터를 적용합니다
  void _applyFilters() {
    setState(() {
      filteredRaces = races.where((race) {
        // 트랙 필터
        if (selectedTrack != null && !race.track.contains(selectedTrack!)) {
          return false;
        }

        // 거리 필터
        if (race.distance < distanceRange.start || race.distance > distanceRange.end) {
          return false;
        }

        // 날짜 필터
        if (selectedDate != null) {
          final raceDate = DateTime.parse(race.raceDate);
          if (raceDate.year != selectedDate!.year ||
              raceDate.month != selectedDate!.month ||
              raceDate.day != selectedDate!.day) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  /// 필터를 초기화합니다
  void _resetFilters() {
    setState(() {
      selectedTrack = null;
      distanceRange = const RangeValues(1000, 2000);
      selectedDate = null;
      filteredRaces = races;
    });
  }

  /// 경주 목록을 빌드합니다
  Widget _buildRaceList(List<RaceModel> raceList) {
    // 로딩 중
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러 발생
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              '오류 발생',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadRaces,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 필터링된 경주 목록이 비어있음
    if (raceList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '경주가 없습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '필터 조건에 맞는 경주 데이터가 없습니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // 경주 목록 표시
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: raceList.length,
      itemBuilder: (context, index) {
        final race = raceList[index];
        return _buildRaceCard(race);
      },
    );
  }

  /// 경주 카드를 빌드합니다
  Widget _buildRaceCard(RaceModel race) {
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
        // 오른쪽 화살표 아이콘
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
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
}
