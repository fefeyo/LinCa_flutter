
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:retrofit/http.dart';

part 'api_client.g.dart';

final Provider<ApiClient> apiClientProvider =
Provider<ApiClient>((Ref<ApiClient> ref) {
  return ApiClient(Dio(_dioOption));
});

final BaseOptions _dioOption = BaseOptions(
  baseUrl: 'https://jsonplaceholder.typicode.com',
  contentType: 'application/json',
);

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio) = _ApiClient;

}
