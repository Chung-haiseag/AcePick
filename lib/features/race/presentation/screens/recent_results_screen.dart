import 'package:flutter/material.dart';
import '../../data/repositories/kra_race_repository.dart';
import '../../data/models/kra/kra_race_result_response.dart';

/// 최근 경기 결과 화면
class RecentResultsScreen extends StatefulWidget {
  const RecentResultsScreen({Key? key}) : super(key: key);

  @override
  State<RecentResultsScreen> createState() => _RecentResultsScreenState();
}

class _RecentResultsScreenState extends State<RecentResultsScreen> {
  final KraRaceRepository _repository = KraRaceRepository();

  // 필터 상태
  String _selectedMeet = 'all'; // 'all', '1'(서울), '2'(제주), '3'(부산경남)
  int _selectedDays = 7; // 7, 14, 30

  // 데이터 상태
  bool _isLoading = false;
  List<RaceResultGroup> _results = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  /// 경기 결과 로드
  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = <RaceResultGroup>[];
      final now = DateTime.now();

      // 최근 N일 동안의 경주 조회
      for (int i = 1; i <= _selectedDays; i++) {
        final date = now.subtract(Duration(days: i));
        final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

        try {
          // KRA API 호출
          final kraItems = await KraApiService().getAllRacesForDate(dateStr);

          if (kraItems.isNotEmpty) {
            // 경마장별로 그룹화
            final groupedByMeet = <String, List<KraRaceItem>>{};
            for (var item in kraItems) {
              final meet = item.meet ?? '1';
              if (!groupedByMeet.containsKey(meet)) {
                groupedByMeet[meet] = [];
              }
              groupedByMeet[meet]!.add(item);
            }

            // 경주별로 그룹화
            for (var entry in groupedByMeet.entries) {
              final meet = entry.key;
              final items = entry.value;

              // 필터링: 경마장
              if (_selectedMeet != 'all' && meet != _selectedMeet) {
                continue;
              }

              // 경주번호별로 그룹화
              final groupedByRace = <String, List<KraRaceItem>>{};
              for (var item in items) {
                final rcNo = (item.rcNo ?? 1).toString();
                if (!groupedByRace.containsKey(rcNo)) {
                  groupedByRace[rcNo] = [];
                }
                groupedByRace[rcNo]!.add(item);
              }

              // RaceResultGroup 생성
              for (var raceEntry in groupedByRace.entries) {
                final rcNo = raceEntry.key;
                final raceItems = raceEntry.value;

                // 순위별로 정렬
                raceItems.sort((a, b) {
                  final ordA = int.tryParse(a.ord?.toString() ?? '999') ?? 999;
                  final ordB = int.tryParse(b.ord?.toString() ?? '999') ?? 999;
                  return ordA.compareTo(ordB);
                });

                results.add(RaceResultGroup(
                  date: dateStr,
                  meet: meet,
                  rcNo: rcNo,
                  items: raceItems,
                ));
              }
            }
          }
        } catch (e) {
          print('⚠️  Error loading results for $dateStr: $e');
          // 에러 발생 시 다음 날짜로 계속 진행
        }
      }

      // 날짜 역순 정렬 (최신순)
      results.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '데이터 로드 실패: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('최근 경기 결과'),
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResults,
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 영역
          _buildFilterSection(),

          // 결과 리스트
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }

  /// 필터 섹션
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기간 필터
          Row(
            children: [
              const Text('기간: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _buildPeriodChip(7, '최근 7일'),
              const SizedBox(width: 8),
              _buildPeriodChip(14, '최근 14일'),
              const SizedBox(width: 8),
              _buildPeriodChip(30, '최근 30일'),
            ],
          ),
          const SizedBox(height: 12),

          // 경마장 필터
          Row(
            children: [
              const Text('경마장: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _buildMeetChip('all', '전체'),
              const SizedBox(width: 8),
              _buildMeetChip('1', '서울'),
              const SizedBox(width: 8),
              _buildMeetChip('2', '제주'),
              const SizedBox(width: 8),
              _buildMeetChip('3', '부산경남'),
            ],
          ),
        ],
      ),
    );
  }

  /// 기간 필터 칩
  Widget _buildPeriodChip(int days, String label) {
    final isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays = days;
        });
        _loadResults();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 경마장 필터 칩
  Widget _buildMeetChip(String meetCode, String label) {
    final isSelected = _selectedMeet == meetCode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMeet = meetCode;
        });
        _loadResults();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 결과 리스트
  Widget _buildResultsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadResults,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '최근 $_selectedDays일 동안 경기 결과가 없습니다',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildRaceResultCard(result);
      },
    );
  }

  /// 경주 결과 카드
  Widget _buildRaceResultCard(RaceResultGroup result) {
    final meetName = _getMeetName(result.meet);
    final dateStr = _formatDate(result.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            // 날짜
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 경마장
            Text(
              meetName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),

            // 경주 번호
            Text(
              '${result.rcNo}경주',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${result.items.length}마리 출전',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        children: [
          // 경주 결과 테이블
          _buildResultTable(result.items),
        ],
      ),
    );
  }

  /// 결과 테이블
  Widget _buildResultTable(List<KraRaceItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Table(
        border: TableBorder.all(color: Colors.grey[300]!),
        columnWidths: const {
          0: FlexColumnWidth(1), // 순위
          1: FlexColumnWidth(2), // 마명
          2: FlexColumnWidth(2), // 기수
          3: FlexColumnWidth(1.5), // 배당
        },
        children: [
          // 헤더
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            children: const [
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '순위',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '마명',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '기수',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '배당',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          // 데이터 행
          ...items.take(10).map((item) {
            final ord = item.ord?.toString() ?? '-';
            final hrName = item.hrName ?? '-';
            final jkName = item.jkName ?? '-';
            final winOdds = item.winOdds?.toString() ?? '-';

            // 1~3위 배경색
            Color? bgColor;
            if (ord == '1') {
              bgColor = Colors.amber[50];
            } else if (ord == '2') {
              bgColor = Colors.grey[100];
            } else if (ord == '3') {
              bgColor = Colors.brown[50];
            }

            return TableRow(
              decoration: BoxDecoration(color: bgColor),
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      ord,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: ord == '1' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      hrName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      jkName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      winOdds,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 경마장 이름 변환
  String _getMeetName(String meetCode) {
    switch (meetCode) {
      case '1':
        return '서울';
      case '2':
        return '제주';
      case '3':
        return '부산경남';
      default:
        return '알 수 없음';
    }
  }

  /// 날짜 포맷 변환 (YYYYMMDD → YYYY-MM-DD)
  String _formatDate(String date) {
    if (date.length == 8) {
      return '${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)}';
    }
    return date;
  }
}

/// 경주 결과 그룹
class RaceResultGroup {
  final String date; // YYYYMMDD
  final String meet; // 경마장 코드
  final String rcNo; // 경주 번호
  final List<KraRaceItem> items; // 출전마 리스트

  RaceResultGroup({
    required this.date,
    required this.meet,
    required this.rcNo,
    required this.items,
  });
}
