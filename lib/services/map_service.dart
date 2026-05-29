import '../constants/api_constants.dart';
import '../models/map_rotation.dart';
import 'api_service.dart';

class MapService {
  final ApiService _api;
  MapService(this._api);

  Future<ApiResult<MapRotation>> getMapRotation() async {
    // Map rotation contains live countdown timers — always fetch fresh.
    final result = await _api.get(
      ApiConstants.mapRotationPath,
      params: {'version': ApiConstants.mapRotationVersion},
      noCache: true,
    );
    return ApiResult(MapRotation.fromJson(result.data));
  }
}
