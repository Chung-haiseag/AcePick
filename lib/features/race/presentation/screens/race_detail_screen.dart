import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:acepick/features/race/data/models/race_model.dart';
import 'package:acepick/features/race/presentation/widgets/confidence_bar.dart';
import 'package:acepick/features/race/presentation/widgets/ai_confidence_indicator.dart';

/// 경주 상세 정보 화면
///
/// 선택한 경주의 상세 정보와 출전 말들의 정보를 표시합니다.
class RaceDetailScreen extends StatelessWidget {
  /// 표시할 경주 정보
  final RaceModel race;

  const RaceDetailScreen({
    super.key,
    required this.race,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${race.track} ${race.raceNumber}경주'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
      ),
      body: Column(
        children: [
          // 경주 정보 헤더
          _buildRaceInfo(),
          // 출전 말 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: race.horses.length,
              itemBuilder: (context, index) {
                final horse = race.horses[index];
                return _buildHorseCardWithExpansion(context, horse, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 경주 정보 헤더를 빌드합니다
  Widget _buildRaceInfo() {
    return Container(
      color: Colors.blue[700],
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('거리', '${race.distance}m'),
          _buildInfoItem('일자', race.raceDate),
          _buildInfoItem('출전', '${race.horses.length}두'),
        ],
      ),
    );
  }

  /// 경주 정보 항목을 빌드합니다
  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 확장 가능한 말 카드를 빌드합니다
  Widget _buildHorseCardWithExpansion(BuildContext context, HorseEntry horse, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // AI 예측 설명 다이얼로그 표시
          showDialog(
            context: context,
            builder: (context) => AiPredictionExplainerDialog(
              horseName: horse.horseName,
              rank: horse.aiPrediction.rank,
              confidence: horse.aiPrediction.confidence,
            ),
          );
        },
        child: ExpansionTile(
        title: _buildHorseCardHeader(horse),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 구간 기록 그래프
                _buildSectionalTimesChart(horse),
                const SizedBox(height: 24),
                // 최근 성적 추이
                _buildRecentFormChart(horse),
                const SizedBox(height: 24),
                // 혈통 정보
                _buildPedigreeInfo(horse),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  /// 말 카드 헤더를 빌드합니다
  Widget _buildHorseCardHeader(HorseEntry horse) {
    return Row(
      children: [
        // AI 순위 배지
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getRankColor(horse.aiPrediction.rank),
          ),
          child: Center(
            child: Text(
              '${horse.aiPrediction.rank}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // 간격
        const SizedBox(width: 16),
        // 말 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 말 이름
              Text(
                horse.horseName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // 기수 및 게이트
              Text(
                '기수: ${horse.jockey} | ${horse.gate}번 게이트',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              // 배당 및 신뢰도
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '배당: ${horse.odds.toStringAsFixed(2)}배',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[600],
                    ),
                  ),
                  Text(
                    '신뢰도: ${(horse.aiPrediction.confidence * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // AI 신뢰도 인디케이터
              Row(
                children: [
                  AiConfidenceIndicator(
                    rank: horse.aiPrediction.rank,
                    confidence: horse.aiPrediction.confidence,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 구간 기록 막대 그래프를 빌드합니다
  Widget _buildSectionalTimesChart(HorseEntry horse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '구간 기록 (초)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 45,
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: horse.sectionalTimes.first600m,
                      color: Colors.blue,
                      width: 20,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: horse.sectionalTimes.second600m,
                      color: Colors.green,
                      width: 20,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: horse.sectionalTimes.last600m,
                      color: Colors.orange,
                      width: 20,
                    ),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('1구간');
                        case 1:
                          return const Text('2구간');
                        case 2:
                          return const Text('3구간');
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}s');
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 구간 기록 상세 정보
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSectionalTimeInfo(
              '1구간 (600m)',
              '${horse.sectionalTimes.first600m.toStringAsFixed(2)}초',
              Colors.blue,
            ),
            _buildSectionalTimeInfo(
              '2구간 (600m)',
              '${horse.sectionalTimes.second600m.toStringAsFixed(2)}초',
              Colors.green,
            ),
            _buildSectionalTimeInfo(
              '3구간 (600m)',
              '${horse.sectionalTimes.last600m.toStringAsFixed(2)}초',
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 가속도 점수
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '가속도 점수',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${horse.sectionalTimes.accelerationScore.toStringAsFixed(1)}/100',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 구간 기록 정보를 빌드합니다
  Widget _buildSectionalTimeInfo(String label, String time, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 최근 성적 추이 라인 차트를 빌드합니다
  Widget _buildRecentFormChart(HorseEntry horse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 성적 추이 (최근 5경주)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              maxY: 12,
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 2,
                verticalInterval: 1,
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < horse.recentForm.length) {
                        return Text('${index + 1}경');
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const Text('1등');
                      } else if (value == 12) {
                        return const Text('12등');
                      }
                      return Text('${value.toInt()}');
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    horse.recentForm.length,
                    (index) => FlSpot(
                      index.toDouble(),
                      horse.recentForm[index].toDouble(),
                    ),
                  ),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: Colors.blue,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 최근 성적 상세 정보
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '최근 5경주 순위',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                horse.recentForm.map((rank) => '$rank등').join(' → '),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 혈통 정보를 빌드합니다
  Widget _buildPedigreeInfo(HorseEntry horse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '혈통 정보',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '부마 (부계):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      horse.pedigree.sire,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    '모마 (모계):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      horse.pedigree.dam,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    '부마 우승률:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(horse.pedigree.sireWinRate * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 순위에 따른 색상을 반환합니다
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;      // 금색
      case 2:
        return Colors.grey[400]!; // 은색
      case 3:
        return Colors.brown[300]!; // 동색
      default:
        return Colors.blue[300]!;  // 파란색
    }
  }
}
