import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/server_status.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

class ServerStatusNotifier extends AsyncNotifier<ApiResult<ServerStatus>> {
  @override
  Future<ApiResult<ServerStatus>> build() {
    return ref.watch(serverServiceProvider).getServerStatus();
  }
}

final serverStatusProvider =
    AsyncNotifierProvider<ServerStatusNotifier, ApiResult<ServerStatus>>(
      ServerStatusNotifier.new,
    );
