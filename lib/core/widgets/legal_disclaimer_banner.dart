import 'package:flutter/material.dart';

/// 법적 면책 배너 위젯
///
/// 서비스의 법적 고지 사항을 표시하는 배너입니다.
/// 빨간색 배경에 경고 아이콘과 함께 면책 문구를 표시합니다.
class LegalDisclaimerBanner extends StatelessWidget {
  /// 배너의 높이 (선택사항)
  final double? height;

  /// 배너의 패딩 (기본값: 12)
  final EdgeInsets padding;

  /// 배너의 배경색 (기본값: Colors.red[50])
  final Color? backgroundColor;

  /// 아이콘 색상 (기본값: Colors.red)
  final Color? iconColor;

  /// 텍스트 색상 (기본값: Colors.red[900])
  final Color? textColor;

  /// 아이콘 크기 (기본값: 20)
  final double iconSize;

  /// 텍스트 크기 (기본값: 12)
  final double fontSize;

  /// 아이콘과 텍스트 사이의 간격 (기본값: 8)
  final double spacing;

  const LegalDisclaimerBanner({
    super.key,
    this.height,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.iconSize = 20,
    this.fontSize = 12,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      color: backgroundColor ?? Colors.red[50],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 경고 아이콘
          Icon(
            Icons.warning,
            color: iconColor ?? Colors.red,
            size: iconSize,
          ),
          // 아이콘과 텍스트 사이 간격
          SizedBox(width: spacing),
          // 면책 문구 텍스트
          Expanded(
            child: Text(
              '본 서비스는 정보 제공 목적이며, 베팅을 권유하거나 중개하지 않습니다.',
              style: TextStyle(
                fontSize: fontSize,
                color: textColor ?? Colors.red[900],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
