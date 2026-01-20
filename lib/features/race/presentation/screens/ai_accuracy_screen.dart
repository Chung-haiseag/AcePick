import 'package:flutter/material.dart';
import '../../../../core/ai/prediction_service.dart';
import '../../data/repositories/race_repository.dart';

class AiAccuracyScreen extends StatefulWidget {
  @override
  _AiAccuracyScreenState createState() => _AiAccuracyScreenState();
}

class _AiAccuracyScreenState extends State<AiAccuracyScreen> {
  bool isLoading = true;
  Map<String, dynamic>? accuracyData;

  @override
  void initState() {
    super.initState();
    _evaluateAccuracy();
  }

  Future<void> _evaluateAccuracy() async {
    setState(() => isLoading = true);

    try {
      // TODO: 과거 경주 데이터로 평가
      // 현재는 더미 데이터
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        accuracyData = {
          'accuracy': 0.42,       // 정확히 맞춘 비율
          'top3_accuracy': 0.68,  // Top 3 예측 정확도
          'mae': 1.8,             // 평균 절대 오차
          'exact_matches': 42,
          'total': 100,
        };
        isLoading = false;
      });
    } catch (e) {
      print('Error evaluating accuracy: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 예측 정확도'),
        backgroundColor: Colors.blue[700],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24),
                    _buildAccuracyCards(),
                    SizedBox(height: 24),
                    _buildChartPlaceholder(),
                    SizedBox(height: 24),
                    _buildExplanation(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: Colors.white, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rule-Based AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '지난 100경주 평가 결과',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: '정확도',
            value: '${(accuracyData!['accuracy'] * 100).toInt()}%',
            subtitle: '${accuracyData!['exact_matches']}/${accuracyData!['total']}',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Top 3 정확도',
            value: '${(accuracyData!['top3_accuracy'] * 100).toInt()}%',
            subtitle: '상위 3위 예측',
            icon: Icons.emoji_events,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '순위별 정확도',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: Center(
                child: Text(
                  '차트는 fl_chart로 구현 예정',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text(
                  '지표 설명',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildExplanationItem(
              '정확도',
              'AI가 정확히 순위를 맞춘 비율입니다.',
            ),
            _buildExplanationItem(
              'Top 3 정확도',
              'AI가 예측한 상위 3마리가 실제로 상위 3위 안에 든 비율입니다.',
            ),
            _buildExplanationItem(
              'MAE (평균 절대 오차)',
              '예측 순위와 실제 순위의 평균 차이입니다. 낮을수록 좋습니다.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $title',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            '  $description',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
