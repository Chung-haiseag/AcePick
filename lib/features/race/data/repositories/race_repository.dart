import '../models/race_model.dart';

abstract class RaceRepository {
  Future<List<RaceModel>> getRaces(String date);
  Future<RaceModel> getRaceDetail(String raceId);
  Future<List<RaceModel>> getUpcomingRaces(int days);
}
