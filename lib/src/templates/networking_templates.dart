abstract class NetworkingTemplates {
  static const String dioClient = '''import 'package:dio/dio.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    
    // Add default interceptors here
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
''';

  static const String graphqlClient = '''import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQlApiClient {
  GraphQlApiClient() {
    final httpLink = HttpLink('https://api.example.com/graphql');

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
