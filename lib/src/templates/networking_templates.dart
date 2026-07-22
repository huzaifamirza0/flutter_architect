abstract class NetworkingTemplates {
  static const String dioClient = '''import 'package:dio/dio.dart';
import '../../app/config/env_config.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: EnvConfig.connectTimeout,
        receiveTimeout: EnvConfig.receiveTimeout,
      ),
    );

    if (EnvConfig.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
''';

  static const String graphqlClient = '''import 'package:graphql_flutter/graphql_flutter.dart';
import '../../app/config/env_config.dart';

class GraphQlApiClient {
  GraphQlApiClient() {
    final httpLink = HttpLink(EnvConfig.graphqlUrl);

    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  late final GraphQLClient _client;

  GraphQLClient get client => _client;
}
''';

  static const String networkInfo = '''abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  // Uncomment and implement with internet_connection_checker
  // NetworkInfoImpl(this.connectionChecker);
  // final InternetConnectionChecker connectionChecker;

  @override
  Future<bool> get isConnected => Future.value(true);
}
''';
}
