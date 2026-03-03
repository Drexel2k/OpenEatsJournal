import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:openeatsjournal/ui/utils/overlay_display.dart';

@GenerateMocks([Callbacks, OverlayDisplay])
//Class for mocking functions for Mockito
abstract class Callbacks {
  Future<Response> get(Uri? url, {Map<String, String>? headers});
}
