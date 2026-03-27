import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:openeatsjournal/domain/eats_journal_entry.dart';
import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/service/assets/open_eats_journal_assets_service.dart';
import 'package:openeatsjournal/ui/utils/overlay_display.dart';

@GenerateMocks([Functions, OverlayDisplay, OpenEatsJournalAssetsService])
//Class for mocking functions for Mockito
abstract class Functions {
  Future<Response> httpGet(Uri? url, {Map<String, String>? headers});
  Food getFood();
  EatsJournalEntry getEatsJournalEntry();
}
