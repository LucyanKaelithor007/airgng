import '../core/app_config.dart';
import '../data/mock_data.dart';
import '../models/jelajahi_data.dart';
import 'api_client.dart';

class JelajahiService {
  final ApiClient _api = ApiClient();

  /// GET /api/jelajahi
  Future<JelajahiData> getJelajahi() async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return MockData.jelajahi();
    }
    final res = await _api.get('/jelajahi');
    return JelajahiData.fromJson(res['data'] as Map<String, dynamic>);
  }
}
