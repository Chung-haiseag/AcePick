// lib/features/result/presentation/screens/race_result_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/race_result_model.dart';

class RaceResultDetailScreen extends StatelessWidget {
  final RaceResult result;

  const RaceResultDetailScreen({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: Text('${result.track} ${result.raceName}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 경주 정보 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.raceName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateFormat.format(result.raceDate),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip('경마장', result.track),
                      const SizedBox(width: 8),
                      _buildInfoChip('거리', '${result.distance}m'),
                      const SizedBox(width: 8),
                      _buildInfoChip('등급', result.grade),
                    ],
                  ),
                ],
              ),
            ),

            // 배당금 정보
            if (result.dividends.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💰 배당금',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: result.dividends.entries.map((entry) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${entry.value.toStringAsFixed(1)}배',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 경주 결과 테이블
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🏇 경주 결과',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultsTable(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildResultsTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FixedColumnWidth(40),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FixedColumnWidth(60),
        4: FixedColumnWidth(60),
      },
      children: [
        // 헤더
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            _TableHeaderCell('순위'),
            _TableHeaderCell('마명'),
            _TableHeaderCell('기수'),
            _TableHeaderCell('기록'),
            _TableHeaderCell('배당'),
          ],
        ),
        // 데이터 행
        ...result.results.map((horse) {
          return TableRow(
            decoration: BoxDecoration(
              color: _getRankColor(horse.rank),
            ),
            children: [
              _TableCell(horse.rank.toString(), bold: true),
              _TableCell(horse.horseName),
              _TableCell(horse.jockeyName),
              _TableCell(horse.recordTime),
              _TableCell('${horse.odds.toStringAsFixed(1)}배'),
            ],
          );
        }).toList(),
      ],
    );
  }

  Color? _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade50;
      case 2:
        return Colors.grey.shade100;
      case 3:
        return Colors.orange.shade50;
      default:
        return null;
    }
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool bold;

  const _TableCell(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
