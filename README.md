# AcePick MVP

**AcePick**은 경마 경주 정보를 분석하고 AI 기반 예측을 제공하는 Flutter 모바일 애플리케이션입니다. 사용자는 경주 정보, 말 상세 데이터, 팁스터 랭킹을 통해 정보 기반의 의사결정을 할 수 있습니다.

## 🎯 주요 기능

### 1. **경주 정보 및 검색**
- 서울, 부산, 제주 경마장의 경주 목록 표시
- 경주 ID 및 트랙명으로 실시간 검색
- 거리, 날짜 기반 필터링
- 경주 상세 정보 조회

### 2. **말 상세 분석**
- 각 말의 구간 기록 시각화 (BarChart)
- 최근 5경주 성적 추이 (LineChart)
- 혈통 정보 및 기수/조련사 정보
- 배당률 및 신뢰도 점수 표시

### 3. **팁스터 랭킹 및 포트폴리오**
- 상위 팁스터 Trust Index 기반 랭킹
- 팁스터 정확도, ROI, Sharpe Ratio 분석
- 가상 자산 관리 (₩1,000,000 초기값)
- 거래 내역 추적

## 🛠 기술 스택

| 카테고리 | 기술 |
|---------|------|
| **프레임워크** | Flutter 3.38.7 |
| **언어** | Dart 3.x |
| **백엔드** | Firebase (Firestore, Auth, Storage) |
| **상태 관리** | Provider 6.0.0 |
| **차트** | fl_chart 0.68.0 |
| **로컬 알림** | flutter_local_notifications 16.3.0 |
| **테스트** | flutter_test |
| **빌드** | Flutter Web, Android, iOS |

## 📦 설치 방법

### 1. 필수 요구사항
- Flutter SDK 3.x 이상
- Dart 3.x 이상
- Node.js 22.x 이상 (웹 빌드용)

### 2. 프로젝트 클론
```bash
git clone <repository-url>
cd AcePick
```

### 3. 의존성 설치
```bash
flutter pub get
```

### 4. Firebase 설정
```bash
# FlutterFire CLI 활성화
dart pub global activate flutterfire_cli

# Firebase 프로젝트 구성
flutterfire configure
```

### 5. 앱 실행

**웹 버전:**
```bash
flutter run -d chrome
```

**Android:**
```bash
flutter run -d android
```

**iOS:**
```bash
flutter run -d ios
```

### 6. 웹 빌드 및 배포
```bash
# 웹 버전 빌드
flutter build web --release

# Nginx에 배포
sudo cp -r build/web/* /var/www/acepick/
```

## 📁 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점, Firebase 초기화
├── core/
│   ├── data/
│   │   └── mock_data_loader.dart      # 모의 데이터 로더
│   ├── services/
│   │   └── notification_service.dart  # 로컬 알림 서비스
│   └── theme/
│       └── app_theme.dart             # 앱 테마 설정
├── features/
│   ├── race/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── race_model.dart    # 경주 데이터 모델
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── home_screen.dart   # 홈 화면 (BottomNavigationBar)
│   │       │   └── race_detail_screen.dart  # 경주 상세 화면
│   │       └── widgets/
│   │           └── race_search_delegate.dart # 경주 검색 위젯
│   ├── tipster/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── tipster_model.dart # 팁스터 데이터 모델
│   │   └── presentation/
│   │       └── screens/
│   │           └── tipster_list_screen.dart  # 팁스터 목록 화면
│   ├── portfolio/
│   │   └── presentation/
│   │       └── screens/
│   │           └── portfolio_screen.dart     # 포트폴리오 화면
│   └── auth/
│       └── presentation/
│           └── screens/
│               └── login_screen.dart  # 로그인 화면
└── test/
    ├── models/
    │   └── race_model_test.dart       # RaceModel 단위 테스트
    └── data/
        └── mock_data_loader_test.dart # MockDataLoader 단위 테스트
```

### 주요 디렉토리 설명

| 디렉토리 | 설명 |
|---------|------|
| `lib/core/` | 공통 기능 (테마, 서비스, 유틸리티) |
| `lib/features/` | 기능별 모듈 (race, tipster, portfolio, auth) |
| `lib/features/*/data/` | 데이터 모델 및 저장소 |
| `lib/features/*/presentation/` | UI 화면 및 위젯 |
| `test/` | 단위 테스트 및 통합 테스트 |

## 📸 스크린샷

### 홈 화면
- 경주 목록 표시 (서울, 부산 경마장)
- AppBar에 검색 및 필터 버튼
- BottomNavigationBar (홈, 팁스터, 포트폴리오)

### 경주 상세 화면
- 경주 정보 (날짜, 거리, 트랙)
- 출전 말 목록 (ExpansionTile)
- 구간 기록 막대 그래프 (BarChart)
- 최근 성적 추이 라인 차트 (LineChart)
- 혈통 정보

### 팁스터 화면
- 상위 팁스터 랭킹
- Trust Index 게이지
- 정확도, ROI, Sharpe Ratio 표시

### 포트폴리오 화면
- 가상 자산 카드 (₩1,000,000)
- 성과 분석 (총 수익, ROI, Sharpe Ratio)
- 거래 내역

## 🔐 법적 고지

**⚠️ 중요 공지:**

본 애플리케이션은 **정보 제공 목적**으로만 제작되었습니다. 다음 사항을 명시합니다:

1. **베팅 권유 금지**: 본 앱은 경마 베팅을 권유하거나 장려하지 않습니다.
2. **정보성 제공**: 제공되는 모든 정보는 참고용이며, 투자 결정의 기초가 되어서는 안 됩니다.
3. **위험 고지**: 경마 베팅은 높은 위험성을 가지고 있으며, 손실 가능성이 있습니다.
4. **책임 면제**: 본 애플리케이션 사용으로 인한 모든 손실에 대해 개발자는 책임을 지지 않습니다.
5. **법적 준수**: 사용자는 해당 국가/지역의 모든 관련 법규를 준수해야 합니다.

## 📋 라이선스

본 프로젝트는 **MIT 라이선스** 하에 배포됩니다.

```
MIT License

Copyright (c) 2026 AcePick Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🚀 배포 정보

| 환경 | 상태 | URL |
|------|------|-----|
| **웹** | ✅ 배포됨 | https://8080-i3k9wfgss9c73u81q1vto-c70d201a.sg1.manus.computer |
| **Android** | 🔄 개발 중 | - |
| **iOS** | 🔄 개발 중 | - |

## 📞 지원 및 피드백

- **버그 리포트**: GitHub Issues
- **기능 요청**: GitHub Discussions
- **이메일**: support@acepick.dev

## 🙏 감사의 말

- Flutter 커뮤니티
- Firebase 팀
- fl_chart 개발자들

---

**마지막 업데이트**: 2026년 1월 20일  
**버전**: 1.0.0 MVP
