import "dart:convert";
import "dart:io";

import "package:http/http.dart" as http;
import "package:http/http.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_api_strings.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_strings.dart";

class OpenFoodFactsService {
  OpenFoodFactsService._singleton();
  static final OpenFoodFactsService instance = OpenFoodFactsService._singleton();

  late String _barcodeSearchEndpoint;
  late String _textSearchEndpoint;

  late String _appName;
  late String _appVersion;
  late String _appContactMail;
  late bool _useStaging;

  void init({
    required String appName,
    required String appVersion,
    required String appContactMail,
    bool useStaging = false,
  }) {
    _appName = appName;
    _appVersion = appVersion;
    _appContactMail = appContactMail;
    _useStaging = useStaging;

    String domain = "org";
    if (_useStaging) {
      domain = "net";
    }

    //https://openfoodfacts.github.io/openfoodfacts-server/api/
    //https://openfoodfacts.github.io/openfoodfacts-server/api/ref-v2/
    _barcodeSearchEndpoint = "https://world.openfoodfacts.$domain/api/v2/product/";

    //https://openfoodfacts.github.io/search-a-licious/
    //https://openfoodfacts.github.io/search-a-licious/users/ref-openapi/
    //https://search.openfoodfacts.org/docs/
    _textSearchEndpoint = "https://search.openfoodfacts.$domain/search?";
  }

  Future<String?> getFoodByBarcode({required String barcode}) async {
    Map<String, String> headers = {HttpHeaders.userAgentHeader: "$_appName/$_appVersion ($_appContactMail)"};

    if (_useStaging) {
      headers[HttpHeaders.authorizationHeader] = "Basic ${base64.encode(utf8.encode("off:off"))}";
    }

    Response resp = await http.get(
      Uri.parse("$_barcodeSearchEndpoint$barcode?product_type=food&fields=${OpenFoodFactsApiStrings.apiV2AllFields.join(",")}"),
      headers: headers,
    );

    if (resp.statusCode == 200) {
      return resp.body;
    }

    return null;
  }

  Future<String?> getFoodBySearchText({
    required String searchText,
    required String languageCode,
    required int page,
  }) async {
    Map<String, String> headers = {
      HttpHeaders.userAgentHeader: "$_appName/$_appVersion ($_appContactMail)",
      HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
    };

    if (_useStaging) {
      headers[HttpHeaders.authorizationHeader] = "Basic ${base64.encode(utf8.encode("off:off"))}";
    }

    String languageCodes = OpenEatsJournalStrings.en;
    if (languageCode != OpenEatsJournalStrings.en) {
      languageCodes = "$languageCode,$languageCodes";
    }

    Response resp = await http.get(
      Uri.parse(
        "${_textSearchEndpoint}q=$searchText&fields=${OpenFoodFactsApiStrings.searchALiciousAllFields.join(",")}&langs=$languageCodes&page_size=100&page=$page",
      ),
      headers: headers,
    );

    if (resp.statusCode == 200) {
      return resp.body;
    }

    return null;
  }
}
