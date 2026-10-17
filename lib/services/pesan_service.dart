import '../core/app_config.dart';
import '../data/mock_data.dart';
import '../models/percakapan.dart';
import 'api_client.dart';

class PesanService {
  final ApiClient _api = ApiClient();

  /// GET /api/pesan
  Future<List<Percakapan>> getPercakapan() async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.percakapan();
    }
    final res = await _api.get('/pesan');
    return ((res['data'] ?? []) as List)
        .map((e) => Percakapan.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
