// lib/features/result/presentation/screens/race_result_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/kra_detail_api_service.dart';
import '../../data/models/race_result_model.dart';
import 'race_result_detail_screen.dart';

class RaceResultListScreen extends StatefulWidget {
  const RaceResultListScreen({Key? key}) : super(key: key);

  @override
  State<RaceResultListScreen> createState() => _RaceResultListScreenState();
}

class _RaceResultListScreenState extends State<RaceResultListScreen> {
  final KraDetailApiService _apiService = KraDetailApiService();
  
  String _selectedTrack = '전체';
  final List<String> _tracks = ['전체', '서울', '제주', '부산경남'];
  final Map<String, String?> _trackCodes = {
    '전체': null,
    '서울': '1',
    '제주': '2',
    '부산경남': '3',
  };
  
  List<RaceResult> _allResults = [];
  List<RaceResult> _filteredResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRaceResults();
  }

  Future<void> _loadRaceResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 현재 월 조회 (YYYYMM 형식)
      final now = DateTime.now();
      final currentMonth = 
          '${now.year}${now.month.toString().padLeft(2, '0')}';
      
      final results = await _apiService.getMonthlyResults(
        rcMonth: currentMonth,
        meet: _trackCodes[_selectedTrack],
      );

      setState(() {
        _allResults = results;
        _filterResults();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '경주 결과를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _filterResults() {
    setState(() {
      if (_selectedTrack == '전체') {
        _filteredResults = _allResults;
      } else {
        _filteredResults = _allResults
            .where((result) => result.track == _selectedTrack)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('경기 결과'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  '경마장: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _tracks.map((track) {
                        final isSelected = track == _selectedTrack;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(track),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTrack = track;
                                _loadRaceResults();
                              });
                            },
                            backgroundColor: Colors.white24,
                            selectedColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.blue : Colors.white,
                              fontWeight: isSelected 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRaceResults,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_filteredResults.isEmpty) {
      return const Center(
        child: Text('경주 결과가 없습니다.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRaceResults,
      child: ListView.builder(
        itemCount: _filteredResults.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final result = _filteredResults[index];
          return _buildRaceResultCard(result);
        },
      ),
    );
  }

  Widget _buildRaceResultCard(RaceResult result) {
    final dateFormat = DateFormat('MM월 dd일 (E)', 'ko_KR');
    final winner = result.results.firstWhere(
      (h) => h.rank == 1,
      orElse: () => result.results.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RaceResultDetailScreen(result: result),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 경주 정보 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${result.track} ${result.raceName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(result.raceDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getGradeColor(result.grade),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      result.grade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // 우승마 정보
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          winner.horseName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '기수: ${winner.jockeyName} | ${winner.recordTime}초',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${winner.odds.toStringAsFixed(1)}배',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        '단승',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 경주 상세 정보
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn('거리', '${result.distance}m'),
                    _buildInfoColumn('출전', '${result.results.length}두'),
                    _buildInfoColumn('단승', 
                        '${result.dividends['단승']?.toStringAsFixed(1) ?? '-'}배'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    if (grade.contains('G1') || grade.contains('1등급')) {
      return Colors.red;
    } else if (grade.contains('G2') || grade.contains('2등급')) {
      return Colors.orange;
    } else if (grade.contains('G3') || grade.contains('3등급')) {
      return Colors.green;
    }
    return Colors.blue;
  }
}
