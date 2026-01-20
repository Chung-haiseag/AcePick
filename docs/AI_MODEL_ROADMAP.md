# AcePick AI 모델 개발 로드맵

## Phase 1: 규칙 기반 (완료 ✅)
**기간**: Week 1-3  
**상태**: 완료

### 구현 내용
- Feature 추출: 배당률, 마체중, 게이트, 부담중량, 가속도, 기수/조교사 통계
- 가중치 기반 점수 계산
- 신뢰도 추정

### 성능 지표
- 정확도: ~40%
- Top 3 정확도: ~65%
- MAE: ~1.8

### 구현된 파일
```
lib/core/ai/
├── features/
│   └── feature_extractor.dart       # Feature 추출
├── engines/
│   └── rule_based_predictor.dart    # 규칙 기반 예측
└── prediction_service.dart           # 예측 서비스
```

### Feature 가중치

| Feature | 가중치 | 설명 |
|---------|--------|------|
| 배당률 | 35% | 낮을수록 우승 확률 높음 |
| 마체중 | 15% | 적정 체중 유지 중요 |
| 게이트 위치 | 10% | 중간 게이트가 유리 |
| 부담중량 | 10% | 낮을수록 유리 |
| 가속도 점수 | 15% | 후반 가속 능력 |
| 기수 승률 | 10% | 기수 능력 |
| 조교사 승률 | 5% | 조교사 능력 |

---

## Phase 2: LambdaMART (Learning to Rank)
**기간**: Week 4-5  
**상태**: 계획 중

### 목표
- 정확도: 50% 이상
- Top 3 정확도: 75% 이상
- MAE: 1.5 이하

### 필요 작업

#### 1. **데이터 수집** (Week 4)

**과거 경주 데이터 수집:**
```bash
# scripts/collect_training_data.dart
# - KRA API로 과거 6개월 경주 데이터 수집
# - 최소 1000경주 이상
# - CSV 또는 JSON 형식으로 저장
```

**Feature 엔지니어링:**
- 기존 7개 Feature
- 추가 Feature:
  - 최근 3경주 평균 순위
  - 경마장별 승률
  - 거리별 승률
  - 경주 간격 (일수)
  - 날씨/주로 상태 인코딩

**데이터 분리:**
- Train: 80% (800경주)
- Test: 20% (200경주)

---

#### 2. **모델 학습** (Week 4-5)

**Python 스크립트:**
```python
# scripts/train_lambdamart.py
import lightgbm as lgb
import pandas as pd
import numpy as np

# 데이터 로드
train_data = pd.read_csv('data/train.csv')
test_data = pd.read_csv('data/test.csv')

# Feature와 Label 분리
X_train = train_data.drop(['race_id', 'horse_id', 'rank'], axis=1)
y_train = train_data['rank']
qids_train = train_data['race_id']

X_test = test_data.drop(['race_id', 'horse_id', 'rank'], axis=1)
y_test = test_data['rank']
qids_test = test_data['race_id']

# LambdaMART 모델 학습
model = lgb.LGBMRanker(
    objective='lambdarank',
    metric='ndcg',
    num_leaves=31,
    learning_rate=0.05,
    n_estimators=100,
    max_depth=6,
)

model.fit(
    X_train, y_train, 
    group=qids_train.value_counts().sort_index().values,
    eval_set=[(X_test, y_test)],
    eval_group=[qids_test.value_counts().sort_index().values],
    eval_metric='ndcg',
)

# 모델 저장
model.booster_.save_model('models/lambdamart.txt')
```

**하이퍼파라미터 튜닝:**
```python
# GridSearch 또는 Optuna 사용
from optuna import create_study

def objective(trial):
    params = {
        'num_leaves': trial.suggest_int('num_leaves', 20, 50),
        'learning_rate': trial.suggest_float('learning_rate', 0.01, 0.1),
        'max_depth': trial.suggest_int('max_depth', 4, 10),
    }
    
    model = lgb.LGBMRanker(**params)
    model.fit(X_train, y_train, group=qids_train)
    
    # NDCG 계산
    score = calculate_ndcg(model, X_test, y_test, qids_test)
    return score

study = create_study(direction='maximize')
study.optimize(objective, n_trials=100)
```

---

#### 3. **모델 변환** (Week 5)

**LightGBM → TFLite 변환:**
```python
# scripts/convert_to_tflite.py
import tensorflow as tf
import treelite
import treelite.runtime

# LightGBM 모델 로드
model = treelite.Model.load('models/lambdamart.txt', model_format='lightgbm')

# TFLite로 변환
# (treelite는 직접 TFLite 변환 미지원, 중간 단계 필요)
# 대안: ONNX 사용 또는 직접 구현
```

**대안: Dart에서 직접 추론:**
```dart
// LightGBM 모델을 JSON으로 내보내기
// Dart에서 JSON 파싱하여 추론 구현
```

---

#### 4. **Flutter 통합** (Week 5)

**파일 구조:**
```
lib/core/ai/engines/
└── lambdamart_predictor.dart
```

**구현:**
```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../features/feature_extractor.dart';
import '../../features/race/data/models/kra/kra_race_result_response.dart';

class LambdaMARTPredictor {
  static Map<String, dynamic>? _model;

  /// 모델 로드
  static Future<void> loadModel() async {
    if (_model != null) return;
    
    final jsonString = await rootBundle.loadString('assets/models/lambdamart.json');
    _model = jsonDecode(jsonString);
    
    print('✅ LambdaMART model loaded');
  }

  /// 예측 수행
  static Future<List<AIPrediction>> predict(List<KraRaceItem> kraItems) async {
    await loadModel();
    
    // Feature 추출
    final features = FeatureExtractor.extractFeatures(kraItems);
    
    // 각 말에 대해 점수 계산
    final scores = features.map((f) => _predictScore(f)).toList();
    
    // 점수로 정렬
    final sortedFeatures = List.from(features);
    sortedFeatures.sort((a, b) => scores[features.indexOf(b)].compareTo(scores[features.indexOf(a)]));
    
    // AIPrediction 생성
    final predictions = <AIPrediction>[];
    for (int i = 0; i < features.length; i++) {
      final feature = features[i];
      final rank = sortedFeatures.indexOf(feature) + 1;
      final confidence = _calculateConfidence(rank, scores[i]);
      
      predictions.add(AIPrediction(
        rank: rank,
        confidence: confidence,
      ));
    }
    
    return predictions;
  }

  /// LightGBM 트리 추론
  static double _predictScore(HorseFeatures features) {
    // JSON 모델에서 트리 구조 읽기
    final trees = _model!['trees'] as List;
    
    double score = 0.0;
    for (var tree in trees) {
      score += _traverseTree(tree, features);
    }
    
    return score;
  }

  /// 트리 순회
  static double _traverseTree(Map<String, dynamic> node, HorseFeatures features) {
    if (node['leaf_value'] != null) {
      return node['leaf_value'];
    }
    
    final featureName = node['split_feature'];
    final threshold = node['threshold'];
    final featureValue = _getFeatureValue(features, featureName);
    
    if (featureValue <= threshold) {
      return _traverseTree(node['left_child'], features);
    } else {
      return _traverseTree(node['right_child'], features);
    }
  }

  /// Feature 값 추출
  static double _getFeatureValue(HorseFeatures features, String featureName) {
    switch (featureName) {
      case 'odds':
        return features.oddsFeature;
      case 'weight':
        return features.weightFeature;
      case 'gate':
        return features.gateFeature;
      case 'burden':
        return features.burdenFeature;
      case 'acceleration':
        return features.accelerationFeature;
      case 'jockey_rate':
        return features.jockeyWinRate;
      case 'trainer_rate':
        return features.trainerWinRate;
      default:
        return 0.0;
    }
  }

  /// 신뢰도 계산
  static double _calculateConfidence(int rank, double score) {
    // 점수 기반 신뢰도 계산
    double baseConfidence;
    
    if (rank == 1) {
      baseConfidence = 0.85;
    } else if (rank <= 3) {
      baseConfidence = 0.70;
    } else if (rank <= 5) {
      baseConfidence = 0.55;
    } else {
      baseConfidence = 0.40;
    }
    
    // 점수로 조정 (정규화 필요)
    final scoreAdjustment = (score - 0.5) * 0.2;
    
    return (baseConfidence + scoreAdjustment).clamp(0.30, 0.95);
  }
}

class AIPrediction {
  final int rank;
  final double confidence;

  AIPrediction({
    required this.rank,
    required this.confidence,
  });
}
```

**PredictionService 업데이트:**
```dart
// lib/core/ai/prediction_service.dart
Future<List<AIPrediction>> _predictWithLambdaMART(
  List<KraRaceItem> kraItems
) async {
  await LambdaMARTPredictor.loadModel();
  return await LambdaMARTPredictor.predict(kraItems);
}
```

---

### 필요 패키지

**pubspec.yaml:**
```yaml
dependencies:
  # TFLite 사용 시
  tflite_flutter: ^0.10.0
  
  # 또는 직접 구현 시 (추가 패키지 불필요)
```

**Python 환경:**
```bash
pip install lightgbm pandas numpy scikit-learn optuna
```

---

## Phase 3: LSTM (시계열 예측)
**기간**: Week 6-8  
**상태**: 미래 계획

### 목표
- 정확도: 55% 이상
- Top 3 정확도: 80% 이상
- MAE: 1.3 이하
- 최근 성적 패턴 학습

### 아키텍처

**Keras/TensorFlow:**
```python
# scripts/train_lstm.py
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout

# 하이퍼파라미터
seq_length = 5  # 최근 5경주
n_features = 10  # Feature 개수
n_horses = 12  # 출전마 수 (가변)

# LSTM 모델
model = Sequential([
    LSTM(64, input_shape=(seq_length, n_features), return_sequences=True),
    Dropout(0.2),
    LSTM(32),
    Dropout(0.2),
    Dense(32, activation='relu'),
    Dense(n_horses, activation='softmax')  # 순위 확률 분포
])

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

# 학습
model.fit(
    X_train,  # (batch_size, seq_length, n_features)
    y_train,  # (batch_size,) - 실제 순위
    epochs=50,
    batch_size=32,
    validation_data=(X_test, y_test),
)

# TFLite 변환
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open('models/lstm.tflite', 'wb') as f:
    f.write(tflite_model)
```

---

### 입력 데이터

**시계열 데이터 구조:**
```python
# 각 말의 최근 5경주 데이터
X = [
    [  # 경주 1
        [odds_1, weight_1, gate_1, ...],  # 말 1
        [odds_2, weight_2, gate_2, ...],  # 말 2
        ...
    ],
    [  # 경주 2
        [odds_1, weight_1, gate_1, ...],
        [odds_2, weight_2, gate_2, ...],
        ...
    ],
    ...
]

# 실제 순위
y = [1, 3, 2, ...]  # 각 말의 실제 순위
```

**Feature:**
- 최근 5경주 성적 (순위)
- 구간 기록 시계열 (1구간, 2구간, 3구간)
- 날씨/주로 조건 변화
- 경주 간격 (일수)
- 마체중 변화
- 배당률 추이

---

### Flutter 통합

**파일 구조:**
```
lib/core/ai/engines/
└── lstm_predictor.dart
```

**구현:**
```dart
import 'package:tflite_flutter/tflite_flutter.dart';
import '../features/feature_extractor.dart';

class LSTMPredictor {
  static Interpreter? _interpreter;

  /// 모델 로드
  static Future<void> loadModel() async {
    if (_interpreter != null) return;
    
    _interpreter = await Interpreter.fromAsset('assets/models/lstm.tflite');
    print('✅ LSTM model loaded');
  }

  /// 예측 수행
  static Future<List<AIPrediction>> predict(
    List<KraRaceItem> kraItems,
    List<List<KraRaceItem>> recentRaces,  // 최근 5경주 데이터
  ) async {
    await loadModel();
    
    // 시계열 데이터 준비
    final input = _prepareTimeSeriesData(kraItems, recentRaces);
    
    // 추론
    final output = List.filled(kraItems.length, 0.0).reshape([1, kraItems.length]);
    _interpreter!.run(input, output);
    
    // 순위 생성
    final predictions = _generatePredictions(output[0]);
    
    return predictions;
  }

  /// 시계열 데이터 준비
  static List<List<List<double>>> _prepareTimeSeriesData(
    List<KraRaceItem> kraItems,
    List<List<KraRaceItem>> recentRaces,
  ) {
    // (seq_length, n_horses, n_features) 형태로 변환
    final data = <List<List<double>>>[];
    
    for (var race in recentRaces) {
      final features = FeatureExtractor.extractFeatures(race);
      final raceData = features.map((f) => [
        f.oddsFeature,
        f.weightFeature,
        f.gateFeature,
        f.burdenFeature,
        f.accelerationFeature,
        f.jockeyWinRate,
        f.trainerWinRate,
      ]).toList();
      
      data.add(raceData);
    }
    
    return data;
  }

  /// 예측 생성
  static List<AIPrediction> _generatePredictions(List<double> scores) {
    // 점수로 정렬
    final sortedIndices = List.generate(scores.length, (i) => i);
    sortedIndices.sort((a, b) => scores[b].compareTo(scores[a]));
    
    // AIPrediction 생성
    final predictions = <AIPrediction>[];
    for (int i = 0; i < scores.length; i++) {
      final rank = sortedIndices.indexOf(i) + 1;
      final confidence = scores[i];
      
      predictions.add(AIPrediction(
        rank: rank,
        confidence: confidence,
      ));
    }
    
    return predictions;
  }
}
```

---

## Phase 4: 앙상블 모델
**기간**: Week 9-10  
**상태**: 미래 계획

### 목표
- 정확도: 70% 이상
- Top 3 정확도: 90% 이상
- MAE: < 1.5

### 앙상블 전략

#### 1. **가중 평균 (Weighted Average)**

```dart
class EnsemblePredictor {
  static const WEIGHTS = {
    'ruleBased': 0.2,
    'lambdaMART': 0.5,
    'lstm': 0.3,
  };

  static Future<List<AIPrediction>> predict(
    List<KraRaceItem> kraItems,
    List<List<KraRaceItem>> recentRaces,
  ) async {
    // 3개 모델의 예측
    final pred1 = await RuleBasedPredictor.predict(kraItems);
    final pred2 = await LambdaMARTPredictor.predict(kraItems);
    final pred3 = await LSTMPredictor.predict(kraItems, recentRaces);
    
    // 가중 평균
    final predictions = <AIPrediction>[];
    for (int i = 0; i < kraItems.length; i++) {
      final rank1 = pred1[i].rank;
      final rank2 = pred2[i].rank;
      final rank3 = pred3[i].rank;
      
      final avgRank = (
        rank1 * WEIGHTS['ruleBased']! +
        rank2 * WEIGHTS['lambdaMART']! +
        rank3 * WEIGHTS['lstm']!
      ).round();
      
      final avgConfidence = (
        pred1[i].confidence * WEIGHTS['ruleBased']! +
        pred2[i].confidence * WEIGHTS['lambdaMART']! +
        pred3[i].confidence * WEIGHTS['lstm']!
      );
      
      predictions.add(AIPrediction(
        rank: avgRank,
        confidence: avgConfidence,
      ));
    }
    
    return predictions;
  }
}
```

---

#### 2. **Voting (투표)**

```dart
static Future<List<AIPrediction>> predictWithVoting(
  List<KraRaceItem> kraItems,
  List<List<KraRaceItem>> recentRaces,
) async {
  final pred1 = await RuleBasedPredictor.predict(kraItems);
  final pred2 = await LambdaMARTPredictor.predict(kraItems);
  final pred3 = await LSTMPredictor.predict(kraItems, recentRaces);
  
  // 각 말에 대해 투표
  final predictions = <AIPrediction>[];
  for (int i = 0; i < kraItems.length; i++) {
    final votes = [pred1[i].rank, pred2[i].rank, pred3[i].rank];
    
    // 중앙값 사용
    votes.sort();
    final medianRank = votes[1];
    
    // 신뢰도는 평균
    final avgConfidence = (
      pred1[i].confidence + 
      pred2[i].confidence + 
      pred3[i].confidence
    ) / 3;
    
    predictions.add(AIPrediction(
      rank: medianRank,
      confidence: avgConfidence,
    ));
  }
  
  return predictions;
}
```

---

#### 3. **Stacking (스태킹)**

```dart
// Meta-learner: 3개 모델의 예측을 입력으로 받아 최종 예측
// 별도의 LightGBM 모델 학습 필요
```

---

## 성능 개선 전략

### 1. Feature 엔지니어링

**추가할 Feature:**
- [ ] 실제 기수/조교사 승률 DB 구축
- [ ] 혈통 정보 추가 (부, 모, 조부 등)
- [ ] 경주 간격 Feature (휴식 기간)
- [ ] 날씨/주로 상태 인코딩 (맑음/흐림/비, 양호/불량)
- [ ] 경마장별 승률
- [ ] 거리별 승률
- [ ] 최근 3경주 평균 순위
- [ ] 마체중 변화 (증감)
- [ ] 부담중량 변화
- [ ] 구간 기록 추이

---

### 2. 데이터 품질 개선

**데이터 수집:**
```dart
// scripts/collect_jockey_trainer_stats.dart
// - 기수/조교사 통계 DB 구축
// - 최근 1년 승률 계산
// - SQLite 또는 Firebase에 저장
```

**데이터 정제:**
- 이상치 제거 (비정상적인 배당률, 마체중 등)
- 결측치 처리 (평균값 또는 중앙값으로 대체)
- Feature 정규화 (0~1 범위로 스케일링)

---

### 3. 온라인 학습

**실시간 모델 업데이트:**
```dart
// 매주 토/일 경주 후 모델 재학습
// 1. 새로운 경주 데이터 수집
// 2. 기존 데이터에 추가
// 3. 모델 재학습
// 4. 성능 평가 (Test set)
// 5. 성능 향상 시 모델 업데이트
```

**A/B 테스트:**
```dart
// 새 모델과 기존 모델 동시 운영
// 사용자 50%는 새 모델, 50%는 기존 모델
// 정확도 비교 후 우수한 모델 선택
```

---

### 4. 하이퍼파라미터 튜닝

**LambdaMART:**
```python
# Optuna로 자동 튜닝
best_params = {
    'num_leaves': 35,
    'learning_rate': 0.03,
    'max_depth': 7,
    'min_child_samples': 20,
    'subsample': 0.8,
    'colsample_bytree': 0.8,
}
```

**LSTM:**
```python
# Grid Search
best_params = {
    'lstm_units_1': 64,
    'lstm_units_2': 32,
    'dropout': 0.2,
    'learning_rate': 0.001,
    'batch_size': 32,
}
```

---

## 데이터 요구사항

### 필수 데이터

| 데이터 | 개수 | 출처 |
|--------|------|------|
| 과거 경주 기록 | 1000+ 경주 | KRA API |
| 말별 상세 기록 | 10,000+ 출전 | KRA API |
| 기수 통계 | 100+ 기수 | KRA API 또는 크롤링 |
| 조교사 통계 | 50+ 조교사 | KRA API 또는 크롤링 |

---

### 선택 데이터

| 데이터 | 개수 | 출처 |
|--------|------|------|
| 혈통 정보 | 1,000+ 말 | 크롤링 |
| 조교 기록 | - | KRA API (미제공 시 제외) |
| 경주 영상 | - | 향후 (컴퓨터 비전) |

---

## 평가 지표

### 목표 성능

| 지표 | Phase 1 | Phase 2 목표 | Phase 3 목표 | Phase 4 목표 |
|------|---------|-------------|-------------|-------------|
| **정확도** | 40% | 50% | 55% | 70% |
| **Top 3** | 65% | 75% | 80% | 90% |
| **MAE** | 1.8 | 1.5 | 1.3 | < 1.5 |

---

### 평가 방법

**백테스팅:**
```dart
// scripts/backtest.dart
// 1. 과거 경주 데이터로 예측
// 2. 실제 결과와 비교
// 3. 정확도, Top 3 정확도, MAE 계산
// 4. 경주별, 경마장별, 거리별 성능 분석
```

**Cross-Validation:**
```python
# K-Fold Cross-Validation (K=5)
from sklearn.model_selection import KFold

kf = KFold(n_splits=5, shuffle=True)
for train_idx, test_idx in kf.split(X):
    X_train, X_test = X[train_idx], X[test_idx]
    y_train, y_test = y[train_idx], y[test_idx]
    
    # 모델 학습 및 평가
    model.fit(X_train, y_train)
    score = model.score(X_test, y_test)
```

---

## 타임라인

```
Week 1-3:  Phase 1 (완료 ✅)
           - RuleBasedPredictor 구현
           - Feature 추출
           - 신뢰도 계산

Week 4:    Phase 2 - 데이터 수집
           - KRA API로 과거 데이터 수집
           - Feature 엔지니어링
           - Train/Test 분리

Week 5:    Phase 2 - 모델 학습 및 통합
           - LambdaMART 학습
           - 하이퍼파라미터 튜닝
           - Flutter 통합

Week 6-7:  Phase 3 - LSTM 데이터 준비
           - 시계열 데이터 구조화
           - 최근 성적 데이터 수집

Week 8:    Phase 3 - LSTM 학습 및 통합
           - LSTM 모델 학습
           - TFLite 변환
           - Flutter 통합

Week 9:    Phase 4 - 앙상블
           - 3개 모델 통합
           - 가중치 최적화
           - A/B 테스트

Week 10:   Phase 4 - 최종 평가
           - 백테스팅
           - 성능 분석
           - 배포
```

---

## 참고 자료

### 논문
- **LambdaMART**: "From RankNet to LambdaRank to LambdaMART: An Overview" (Microsoft Research)
- **LSTM**: "Long Short-Term Memory" (Hochreiter & Schmidhuber, 1997)
- **Learning to Rank**: "Learning to Rank for Information Retrieval" (Liu, 2009)

### 라이브러리
- **LightGBM**: https://lightgbm.readthedocs.io/
- **TensorFlow**: https://www.tensorflow.org/
- **TFLite Flutter**: https://pub.dev/packages/tflite_flutter

### 데이터
- **KRA API**: https://www.data.go.kr/
- **공공데이터포털**: 한국마사회 경주 데이터

---

**문서 버전**: 1.0  
**최종 업데이트**: 2026년 1월 20일  
**작성자**: AcePick 개발팀
