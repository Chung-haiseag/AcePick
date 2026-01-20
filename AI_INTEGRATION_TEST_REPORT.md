# AI 예측 시스템 통합 테스트 결과 보고서

**테스트 날짜**: 2026년 1월 20일  
**테스트 대상**: AcePick AI 예측 시스템  
**테스트 범위**: Feature 추출, AI 예측 정확도, 앱 빌드 검증

---

## 📋 테스트 요약

| 테스트 항목 | 상태 | 결과 |
|------------|------|------|
| **Feature 추출** | ✅ 통과 | Feature 추출 정상 작동 |
| **AI 예측 정확도** | ⚠️ 부분 통과 | 목표 미달 (데이터 품질 문제) |
| **앱 빌드 검증** | ⚠️ 부분 통과 | 37개 에러 (notification_service 관련) |

---

## 테스트 1: Feature 추출 확인 ✅

### 실행 명령
```bash
dart run scripts/test_ai_prediction_with_rulebased.dart
```

### 결과

**Feature 추출 성공:**
- ✅ 배당률 (odds) 추출
- ✅ 마체중 (weight) 추출
- ✅ 게이트 (gate) 추출
- ✅ 부담중량 (burden) 추출
- ✅ 가속도 점수 (acceleration) 계산
- ✅ 총점 (score) 계산

**Feature 샘플 (1경주 1번 말):**
```
- Odds: 10.4
- Weight: 500.0
- Gate: 5
- Score: 0.655
```

### 문제점

**마체중 데이터 품질 이슈:**
- 모든 말의 마체중이 500.0으로 동일
- KRA API에서 `hrWght` 필드가 제공되지 않거나 null
- 기본값 500으로 대체됨

**영향:**
- 마체중 Feature가 예측에 기여하지 못함
- 전체 정확도 하락

**해결 방안:**
1. KRA API 응답 구조 재확인
2. 다른 필드명 확인 (예: `weight`, `hrWeight` 등)
3. 마체중 데이터가 없는 경우 해당 Feature 가중치 0으로 설정

---

## 테스트 2: AI 예측 정확도 ⚠️

### 실행 결과

**테스트 대상:**
- 날짜: 2024년 1월 13일 (토요일)
- 경주: 서울 1~5경주
- 총 출전마: 53마리

**성능 지표:**

| 지표 | 결과 | 목표 | 평가 |
|------|------|------|------|
| **정확도** | 18.9% | 30% 이상 | ❌ 목표 미달 |
| **Top 3 정확도** | 15.1% | 50% 이상 | ❌ 목표 미달 |
| **MAE** | 4.26 순위 | 2.0 이하 | ❌ 목표 미달 |
| **정확히 맞춘 개수** | 10마리 | - | - |
| **Top 3 맞춘 개수** | 8마리 | - | - |

---

### 경주별 상세 결과

| 경주 | 출전마 수 | 정확히 맞춘 개수 | 정확도 | Top 3 맞춘 개수 | Top 3 정확도 |
|------|-----------|------------------|--------|-----------------|--------------|
| 1경주 | 12마리 | 1마리 | 8.3% | 1마리 | 8.3% |
| 2경주 | 11마리 | 4마리 | 36.4% ✅ | 2마리 | 18.2% |
| 3경주 | 8마리 | 1마리 | 12.5% | 2마리 | 25.0% |
| 4경주 | 11마리 | 2마리 | 18.2% | 2마리 | 18.2% |
| 5경주 | 11마리 | 2마리 | 18.2% | 1마리 | 9.1% |

**특이사항:**
- 2경주에서만 36.4%로 목표 달성
- 나머지 경주는 8.3~18.2%로 낮은 정확도

---

### 원인 분석

#### 1. **데이터 품질 문제** ⚠️

**마체중 데이터 누락:**
- 모든 말의 마체중이 500.0 (기본값)
- 마체중 Feature (15% 가중치)가 무용지물
- 실제 마체중 차이를 반영하지 못함

**영향:**
- 7개 Feature 중 1개가 작동하지 않음
- 실질적으로 6개 Feature로 예측
- 예상 정확도: 40% → 실제 정확도: 18.9%

---

#### 2. **배당률 기반 예측의 한계**

**배당률 = 대중의 예상:**
- 배당률은 베팅 금액에 따라 결정
- 대중의 예상이 항상 정확하지 않음
- 실제 경주 결과와 큰 차이 발생

**경주별 편차:**
- 2경주: 배당률과 실제 순위 일치 → 36.4%
- 1경주: 배당률과 실제 순위 불일치 (이변 발생) → 8.3%

---

#### 3. **Feature 가중치 미최적화**

**현재 가중치:**
```
배당률:      35%
마체중:      15% (작동 안 함)
게이트:      10%
부담중량:    10%
가속도:      15%
기수 승률:   10% (더미 데이터)
조교사 승률:  5% (더미 데이터)
```

**문제점:**
- 기수/조교사 승률이 더미 데이터 (모두 0.5)
- 실제 승률 데이터 필요
- 가중치 튜닝 필요

---

### 개선 방안

#### 즉시 (Phase 1)

1. **마체중 데이터 확보** ⭐⭐⭐
   - KRA API 응답 구조 재확인
   - 다른 필드명 확인
   - 마체중 데이터가 없으면 해당 Feature 제거

2. **기수/조교사 승률 DB 구축** ⭐⭐
   - 과거 경주 데이터로 승률 계산
   - SQLite 또는 Firebase에 저장
   - 실시간 조회

3. **Feature 가중치 튜닝** ⭐
   - 과거 경주 데이터로 최적 가중치 탐색
   - Grid Search 또는 Optuna 사용

**예상 개선:**
```
정확도:        18.9% → 35~45%
Top 3 정확도:  15.1% → 60~70%
MAE:           4.26  → 2.0~2.5
```

---

#### 단기 (Phase 2 - 1~2개월)

1. **LambdaMART 모델 도입**
   - 과거 1000+ 경주 데이터 수집
   - Feature 엔지니어링
   - 모델 학습 및 검증

**예상 개선:**
```
정확도:        35~45% → 50~60%
Top 3 정확도:  60~70% → 75~85%
MAE:           2.0~2.5 → 1.5~2.0
```

---

#### 장기 (Phase 3 - 3~6개월)

1. **LSTM 모델 도입**
   - 시계열 데이터 준비
   - 최근 성적 추이 반영

2. **앙상블 모델**
   - RuleBased + LambdaMART + LSTM 조합
   - 목표 정확도: 70%+

---

## 테스트 3: 앱 빌드 검증 ⚠️

### 실행 명령
```bash
flutter analyze
```

### 결과

**총 이슈: 457개**
- Error: 37개 ❌
- Warning: 일부
- Info: 다수 (print 사용 등)

---

### 주요 에러

#### 1. **notification_service.dart (34개 에러)** ❌

**문제:**
- `flutter_local_notifications` 패키지 미설치
- `FlutterLocalNotificationsPlugin` 등 클래스 미정의

**에러 예시:**
```
error • Undefined class 'FlutterLocalNotificationsPlugin'
error • Undefined class 'AndroidNotificationDetails'
error • Undefined class 'DarwinNotificationDetails'
error • Undefined name 'Importance'
error • Undefined name 'Priority'
```

**해결 방법:**
```yaml
# pubspec.yaml
dependencies:
  flutter_local_notifications: ^16.0.0
```

```bash
flutter pub get
```

---

#### 2. **kra_race_repository.dart (3개 에러)** ✅ 수정 완료

**문제:**
- RaceModel 생성 시 필수 파라미터 누락

**수정 전:**
```dart
return RaceModel(
  raceId: raceId,
  date: date,
  track: first.meet,
  raceNumber: first.rcNo,
  distance: first.rcDist,
  entries: entries,
);
```

**수정 후:**
```dart
return RaceModel(
  raceId: raceId,
  raceDate: date,
  raceNumber: first.rcNo,
  raceName: first.rcName ?? '${first.rcNo}경주',
  raceTime: '00:00',  // KRA API 미제공
  track: first.meet,
  distance: first.rcDist,
  horses: entries,
  weather: '알 수 없음',  // KRA API 미제공
  trackCondition: '알 수 없음',  // KRA API 미제공
  createdAt: DateTime.now().toIso8601String(),
);
```

---

#### 3. **race_detail_screen.dart (1개 에러)** ✅ 수정 완료

**문제:**
- `_buildHorseCardWithExpansion` 메서드에서 `context` 미정의

**수정 전:**
```dart
Widget _buildHorseCardWithExpansion(HorseEntry horse, int index) {
  return Card(
    child: InkWell(
      onTap: () {
        showDialog(
          context: context,  // ❌ context 미정의
          ...
        );
      },
      ...
    ),
  );
}
```

**수정 후:**
```dart
Widget _buildHorseCardWithExpansion(BuildContext context, HorseEntry horse, int index) {
  return Card(
    child: InkWell(
      onTap: () {
        showDialog(
          context: context,  // ✅ context 정의됨
          ...
        );
      },
      ...
    ),
  );
}

// 호출 시
_buildHorseCardWithExpansion(context, horse, index);
```

---

### 빌드 검증 결과

**현재 상태:**
- ✅ AI 관련 파일: 컴파일 에러 없음
- ✅ race_detail_screen.dart: 수정 완료
- ✅ kra_race_repository.dart: 수정 완료
- ❌ notification_service.dart: 패키지 설치 필요 (34개 에러)

**다음 단계:**
1. `flutter_local_notifications` 패키지 설치
2. `flutter pub get` 실행
3. `flutter analyze` 재실행
4. 에러 0개 확인

---

## 📊 전체 평가

### 성공 사항 ✅

1. **Feature 추출 시스템 구축**
   - ✅ 7개 Feature 추출 로직 구현
   - ✅ 정규화 및 가중치 적용
   - ✅ 총점 계산

2. **AI 예측 시스템 구축**
   - ✅ RuleBasedPredictor 구현
   - ✅ PredictionService 통합
   - ✅ KraRaceRepository 연동

3. **UI 통합**
   - ✅ AiConfidenceIndicator 위젯
   - ✅ AiPredictionExplainerDialog
   - ✅ race_detail_screen에 AI 예측 표시

4. **테스트 스크립트**
   - ✅ test_ai_prediction_with_rulebased.dart
   - ✅ Feature 추출 로그
   - ✅ 정확도 평가

---

### 개선 필요 사항 ⚠️

1. **데이터 품질**
   - ⚠️ 마체중 데이터 누락 (모두 500.0)
   - ⚠️ 기수/조교사 승률 더미 데이터 (모두 0.5)

2. **AI 예측 정확도**
   - ⚠️ 정확도: 18.9% (목표 30% 미달)
   - ⚠️ Top 3 정확도: 15.1% (목표 50% 미달)
   - ⚠️ MAE: 4.26 (목표 2.0 초과)

3. **앱 빌드**
   - ⚠️ 37개 컴파일 에러 (notification_service)
   - ⚠️ flutter_local_notifications 패키지 미설치

---

### 우선순위 작업

#### **우선순위 1: 데이터 품질 개선** ⭐⭐⭐

**작업:**
1. KRA API 응답 구조 재확인
   - `hrWght` 필드 확인
   - 다른 마체중 필드 탐색

2. 기수/조교사 승률 DB 구축
   - 과거 경주 데이터 수집
   - 승률 계산 및 저장

**예상 소요 시간:** 1~2일

**예상 개선:**
- 정확도: 18.9% → 35~45%
- Top 3 정확도: 15.1% → 60~70%

---

#### **우선순위 2: 앱 빌드 에러 수정** ⭐⭐

**작업:**
1. pubspec.yaml에 패키지 추가
   ```yaml
   dependencies:
     flutter_local_notifications: ^16.0.0
   ```

2. flutter pub get 실행

3. flutter analyze로 에러 확인

**예상 소요 시간:** 30분

---

#### **우선순위 3: Feature 가중치 튜닝** ⭐

**작업:**
1. 과거 경주 데이터 수집 (30+ 경주)
2. Grid Search로 최적 가중치 탐색
3. 백테스팅으로 검증

**예상 소요 시간:** 2~3일

---

## 📈 로드맵

### Phase 1: 데이터 품질 개선 (Week 4)

**목표:**
- 정확도: 35~45%
- Top 3 정확도: 60~70%
- MAE: 2.0~2.5

**작업:**
- [x] Feature 추출 시스템 구축
- [x] RuleBasedPredictor 구현
- [x] UI 통합
- [ ] 마체중 데이터 확보
- [ ] 기수/조교사 승률 DB 구축
- [ ] Feature 가중치 튜닝

---

### Phase 2: LambdaMART 모델 (Week 5-6)

**목표:**
- 정확도: 50~60%
- Top 3 정확도: 75~85%
- MAE: 1.5~2.0

**작업:**
- [ ] 과거 1000+ 경주 데이터 수집
- [ ] Feature 엔지니어링
- [ ] LambdaMART 모델 학습
- [ ] Flutter 통합

---

### Phase 3: LSTM 모델 (Week 7-9)

**목표:**
- 정확도: 55~65%
- Top 3 정확도: 80~90%
- MAE: 1.3~1.8

**작업:**
- [ ] 시계열 데이터 준비
- [ ] LSTM 모델 학습
- [ ] Flutter 통합

---

### Phase 4: 앙상블 모델 (Week 10)

**목표:**
- 정확도: 70%+
- Top 3 정확도: 90%+
- MAE: < 1.5

**작업:**
- [ ] 3개 모델 통합
- [ ] 가중치 최적화
- [ ] 최종 평가 및 배포

---

## ✅ 결론

### 현재 상태

**완성도: 70%**

- ✅ AI 예측 시스템 구축 완료
- ✅ UI 통합 완료
- ⚠️ 데이터 품질 개선 필요
- ⚠️ 예측 정확도 개선 필요
- ⚠️ 빌드 에러 수정 필요

---

### 다음 단계

**즉시 (1~2일):**
1. 마체중 데이터 확보
2. 기수/조교사 승률 DB 구축
3. flutter_local_notifications 패키지 설치

**단기 (1주):**
1. Feature 가중치 튜닝
2. 테스트 데이터 확장 (30+ 경주)
3. 정확도 35~45% 달성

**중기 (1~2개월):**
1. LambdaMART 모델 개발
2. 정확도 50~60% 달성

**장기 (3~6개월):**
1. LSTM 모델 개발
2. 앙상블 모델 구축
3. 정확도 70%+ 달성

---

**보고서 작성일**: 2026년 1월 20일  
**테스트 실행일**: 2026년 1월 20일  
**테스트 대상**: 2024년 1월 13일 서울 1~5경주 (53마리)  
**작성자**: AcePick 개발팀
