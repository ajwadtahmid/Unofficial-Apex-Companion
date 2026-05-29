import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/predator.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

class PredatorNotifier extends AsyncNotifier<ApiResult<PredatorResponse>> {
  @override
  Future<ApiResult<PredatorResponse>> build() {
    return ref.watch(predatorServiceProvider).getPredator();
  }
}

final predatorProvider =
    AsyncNotifierProvider<PredatorNotifier, ApiResult<PredatorResponse>>(
      PredatorNotifier.new,
    );
