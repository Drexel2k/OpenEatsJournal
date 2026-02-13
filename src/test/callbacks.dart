import 'package:http/http.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([Callbacks])
//Class for mocking functions for Mockito
abstract class Callbacks {
  Future<Response> get(Uri? url, {Map<String, String>? headers});
}