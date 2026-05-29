import '../models/predator.dart';
import 'api_service.dart';

class PredatorService {
  final ApiService _api;
  PredatorService(this._api);

  Future<ApiResult<PredatorResponse>> getPredator() async {
    final result = await _api.get('/predator');
    return ApiResult(
      PredatorResponse.fromJson(result.data),
      staleAt: result.staleAt,
    );
  }
}
