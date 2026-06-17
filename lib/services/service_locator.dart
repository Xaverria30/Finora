import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'preferences_service.dart';
import 'real_api_service.dart';

class ServiceLocator {
  static ApiService getApiService({
    required PreferencesService preferencesService,
  }) {
    return RealApiService(
      httpClient: http.Client(),
      preferencesService: preferencesService,
    );
  }
}
