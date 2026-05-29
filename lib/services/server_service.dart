import '../models/server_status.dart';
import 'api_service.dart';

class ServerService {
  final ApiService _api;
  ServerService(this._api);

  Future<ApiResult<ServerStatus>> getServerStatus() async {
    final result = await _api.get('/servers');
    return ApiResult(
      ServerStatus.fromJson(result.data),
      staleAt: result.staleAt,
    );
  }
}
