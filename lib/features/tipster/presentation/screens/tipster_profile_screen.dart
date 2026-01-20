import 'package:flutter/material.dart';
import 'package:acepick/features/tipster/data/models/tipster_model.dart';
import 'package:acepick/features/tipster/presentation/widgets/trust_index_gauge.dart';

/// 팁스터 프로필 화면
///
/// 팁스터의 상세 정보, 통계, 신뢰도 지수, 최근 예측을 표시합니다.
class TipsterProfileScreen extends StatelessWidget {
  /// 팁스터 정보
  final TipsterModel tipster;

  const TipsterProfileScreen({
    super.key,
    required this.tipster,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tipster.username),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildStatsSection(),
            _buildTrustIndexDetail(),
            _buildRecentPicks(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 프로필 헤더 섹션을 빌드합니다
  Widget _buildProfileHeader() {
    return Container(
      color: Colors.blue[700],
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 프로필 아바타
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              tipster.username.isNotEmpty ? tipster.username[0] : '?',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 사용자명 및 검증 배지
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tipster.username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (tipster.verified)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.verified,
                    size: 24,
                    color: Colors.amber,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 소개 텍스트
          Text(
            '신뢰도 높은 경마 예측 전문가',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 섹션을 빌드합니다
  Widget _buildStatsSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              '총 예측',
              '${tipster.stats.totalPredictions}회',
            ),
            _buildStatItem(
              '적중률',
              '${((tipster.stats.wins / tipster.stats.totalPredictions) * 100).toStringAsFixed(1)}%',
            ),
            _buildStatItem(
              'ROI',
              '${tipster.trustIndex.roi.toStringAsFixed(1)}%',
            ),
            _buildStatItem(
              '팔로워',
              '${tipster.stats.totalFollowers}명',
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 항목을 빌드합니다
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// Trust Index 상세 정보 섹션을 빌드합니다
  Widget _buildTrustIndexDetail() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            const Text(
              'Trust Index 상세',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Trust Index 게이지
            Center(
              child: TrustIndexGauge(
                trustIndex: tipster.trustIndex,
                size: 150,
              ),
            ),
            const SizedBox(height: 24),
            // 컴포넌트별 프로그레스 바
            _buildComponentBar(
              '정확도',
              tipster.trustIndex.components.accuracy,
            ),
            const SizedBox(height: 16),
            _buildComponentBar(
              '일관성',
              tipster.trustIndex.components.consistency,
            ),
            const SizedBox(height: 16),
            _buildComponentBar(
              '예측량',
              tipster.trustIndex.components.volume / 500, // 최대 500으로 정규화
            ),
            const SizedBox(height: 16),
            _buildComponentBar(
              '투명성',
              tipster.trustIndex.components.transparency,
            ),
            const SizedBox(height: 24),
            // Brier Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Brier Score',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tipster.trustIndex.brierScore.toStringAsFixed(3),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 컴포넌트 프로그레스 바를 빌드합니다
  Widget _buildComponentBar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getComponentColor(value),
            ),
          ),
        ),
      ],
    );
  }

  /// 컴포넌트 값에 따른 색상을 반환합니다
  Color _getComponentColor(double value) {
    if (value >= 0.8) {
      return Colors.green;
    } else if (value >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// 최근 예측 섹션을 빌드합니다
  Widget _buildRecentPicks() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            const Text(
              '최근 예측',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // 최근 예측 목록
            if (tipster.recentPicks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('예측 기록이 없습니다'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tipster.recentPicks.length > 10
                    ? 10
                    : tipster.recentPicks.length,
                itemBuilder: (context, index) {
                  final pick = tipster.recentPicks[index];
                  final isAccurate = pick.predictedRank == pick.actualRank;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // 적중 여부 아이콘
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAccurate ? Colors.green : Colors.red,
                          ),
                          child: Icon(
                            isAccurate ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 경주 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pick.raceId,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '예측: ${pick.predictedRank}순위 → 실제: ${pick.actualRank}순위',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 날짜
                        Text(
                          pick.timestamp.split('T')[0],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
