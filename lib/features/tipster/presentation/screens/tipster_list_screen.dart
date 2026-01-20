import 'package:flutter/material.dart';
import 'package:acepick/core/data/mock_data_loader.dart';
import 'package:acepick/features/tipster/data/models/tipster_model.dart';
import 'package:acepick/features/tipster/presentation/screens/tipster_profile_screen.dart';

/// 팁스터 랭킹 화면
///
/// 신뢰도 지수 기준으로 정렬된 팁스터 목록을 표시합니다.
class TipsterListScreen extends StatefulWidget {
  const TipsterListScreen({super.key});

  @override
  State<TipsterListScreen> createState() => _TipsterListScreenState();
}

class _TipsterListScreenState extends State<TipsterListScreen> {
  /// 팁스터 목록
  List<TipsterModel> tipsters = [];

  /// 로딩 상태
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTipsters();
  }

  /// 팁스터 데이터를 로드합니다
  Future<void> _loadTipsters() async {
    try {
      final loadedTipsters = await MockDataLoader.getTopTipsters(limit: 20);
      setState(() {
        tipsters = loadedTipsters;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('팁스터 로드 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팁스터 랭킹'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tipsters.length,
              itemBuilder: (context, index) {
                final tipster = tipsters[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TipsterProfileScreen(tipster: tipster),
                      ),
                    );
                  },
                  child: _buildTipsterCard(tipster, index),
                );
              },
            ),
    );
  }

  /// 팁스터 카드를 빌드합니다
  Widget _buildTipsterCard(TipsterModel tipster, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.bottomRight,
          children: [
            // 프로필 아바타
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[700],
              child: Text(
                tipster.username.isNotEmpty
                    ? tipster.username[0]
                    : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // 검증 배지
            if (tipster.verified)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[700],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            // 팁스터 이름
            Expanded(
              child: Text(
                tipster.username,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 검증 아이콘
            if (tipster.verified)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.verified,
                  size: 16,
                  color: Colors.blue[700],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // 정확도 및 ROI
            Text(
              '정확도: ${(tipster.trustIndex.components.accuracy * 100).toInt()}% · ROI: ${tipster.trustIndex.roi.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            // 예측 수 및 팔로워
            Text(
              '예측 ${tipster.stats.totalPredictions}회 · 팔로워 ${tipster.stats.totalFollowers}명',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trust Index 점수
            Text(
              tipster.trustIndex.score.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 2),
            // 라벨
            const Text(
              'Trust Index',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
