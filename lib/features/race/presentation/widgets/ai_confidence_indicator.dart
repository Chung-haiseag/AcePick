import 'package:flutter/material.dart';

class AiConfidenceIndicator extends StatelessWidget {
  final int rank;
  final double confidence;
  final bool showPercentage;

  const AiConfidenceIndicator({
    Key? key,
    required this.rank,
    required this.confidence,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AI 아이콘
        Icon(
          Icons.psychology,
          color: _getConfidenceColor(),
          size: 16,
        ),
        SizedBox(width: 4),
        
        // 신뢰도 바
        Container(
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                color: _getConfidenceColor(),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        // 퍼센트 표시
        if (showPercentage) ...[
          SizedBox(width: 4),
          Text(
            '${(confidence * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              color: _getConfidenceColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Color _getConfidenceColor() {
    if (confidence >= 0.8) return Colors.green[700]!;
    if (confidence >= 0.6) return Colors.orange[700]!;
    return Colors.red[700]!;
  }
}

/// AI 예측 설명 다이얼로그
class AiPredictionExplainerDialog extends StatelessWidget {
  final String horseName;
  final int rank;
  final double confidence;

  const AiPredictionExplainerDialog({
    Key? key,
    required this.horseName,
    required this.rank,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.psychology, color: Colors.blue[700]),
          SizedBox(width: 8),
          Text('AI 예측 분석'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              horseName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            _buildInfoRow('예측 순위', '$rank위'),
            _buildInfoRow('신뢰도', '${(confidence * 100).toInt()}%'),
            
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            
            Text(
              '신뢰도란?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'AI가 이 예측에 대해 얼마나 확신하는지를 나타냅니다.\n\n'
              '• 80% 이상: 매우 높은 확신\n'
              '• 60-80%: 중간 확신\n'
              '• 60% 미만: 낮은 확신',
              style: TextStyle(fontSize: 13),
            ),
            
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[700]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.amber[700], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '이 정보는 참고용이며, 베팅을 권유하지 않습니다.',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('확인'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
