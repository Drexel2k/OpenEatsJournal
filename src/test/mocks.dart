import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:openeatsjournal/service/assets/open_eats_journal_assets_service.dart';
import 'package:openeatsjournal/ui/utils/overlay_display.dart';

@GenerateMocks([Callbacks, OverlayDisplay, OpenEatsJournalAssetsService])
//Class for mocking functions for Mockito
abstract class Callbacks {
  Future<Response> get(Uri? url, {Map<String, String>? headers});
}
