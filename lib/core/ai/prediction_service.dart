import 'engines/rule_based_predictor.dart';
import '../../features/race/data/models/kra/kra_race_result_response.dart';
import '../../features/race/data/models/race_model.dart';

enum PredictionModel {
  ruleBased,    // 규칙 기반 (현재)
  lambdaMART,   // LambdaMART (Phase 2)
  lstm,         // LSTM (Phase 3)
}

class PredictionService {
  static final PredictionService _instance = PredictionService._internal();
  factory PredictionService() => _instance;
  PredictionService._internal();

  // 현재 사용 중인 모델
  PredictionModel currentModel = PredictionModel.ruleBased;

  /// 경주 예측 수행
  Future<List<AIPrediction>> predictRace(List<KraRaceItem> kraItems) async {
    print('🤖 Using model: ${currentModel.name}');

    switch (currentModel) {
      case PredictionModel.ruleBased:
        return _predictWithRuleBased(kraItems);
      
      case PredictionModel.lambdaMART:
        // TODO: LambdaMART 모델 구현
        throw UnimplementedError('LambdaMART not implemented yet');
      
      case PredictionModel.lstm:
        // TODO: LSTM 모델 구현
        throw UnimplementedError('LSTM not implemented yet');
    }
  }

  /// 규칙 기반 예측
  Future<List<AIPrediction>> _predictWithRuleBased(
    List<KraRaceItem> kraItems
  ) async {
    // 시뮬레이션: 약간의 지연
    await Future.delayed(Duration(milliseconds: 500));

    return RuleBasedPredictor.predict(kraItems);
  }

  /// 예측 모델 변경
  void setModel(PredictionModel model) {
    currentModel = model;
    print('📊 Prediction model changed to: ${model.name}');
  }

  /// 예측 정확도 평가
  Map<String, dynamic> evaluatePrediction({
    required List<AIPrediction> predictions,
    required List<int> actualRanks,
  }) {
    return RuleBasedPredictor.evaluate(
      predictions: predictions,
      actualRanks: actualRanks,
    );
  }
}
