import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 포트폴리오 화면
///
/// 사용자의 가상 자산, 성과 분석, 거래 내역을 표시합니다.
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  /// 가상 자산 (초기 100만원)
  double virtualBalance = 1000000.0;

  /// 현재 수익 (더미 데이터)
  double currentProfit = 125000.0;

  /// 거래 내역 (나중에 구현)
  List<dynamic> transactions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 포트폴리오'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBalanceCard(),
            _buildPerformanceCard(),
            _buildTransactionList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 가상 자산 카드를 빌드합니다
  Widget _buildBalanceCard() {
    final profitRate = (currentProfit / virtualBalance) * 100;
    final isPositive = currentProfit >= 0;

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue[700],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 라벨
            Text(
              '가상 자산',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[300],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // 잔액 표시 (천 단위 콤마)
            Text(
              '₩${NumberFormat('#,##0').format(virtualBalance.toInt())}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // 수익 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '총 수익',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[300],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₩${NumberFormat('#,##0').format(currentProfit.toInt())}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '수익률',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[300],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isPositive ? '+' : ''}${profitRate.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 성과 분석 카드를 빌드합니다
  Widget _buildPerformanceCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            const Text(
              '성과 분석',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 총 수익
            _buildPerformanceRow(
              '총 수익',
              '₩${NumberFormat('#,##0').format(currentProfit.toInt())}',
              Colors.green,
            ),
            const SizedBox(height: 12),
            // ROI
            _buildPerformanceRow(
              'ROI',
              '${((currentProfit / virtualBalance) * 100).toStringAsFixed(2)}%',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            // Sharpe Ratio
            _buildPerformanceRow(
              'Sharpe Ratio',
              '1.24',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// 성과 분석 항목을 빌드합니다
  Widget _buildPerformanceRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 거래 내역 섹션을 빌드합니다
  Widget _buildTransactionList() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            const Text(
              '거래 내역',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 거래 내역 없음 메시지
            if (transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    '아직 거래 내역이 없습니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              // 거래 내역 목록 (나중에 구현)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('거래 ${index + 1}'),
                    subtitle: const Text('거래 내용'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
