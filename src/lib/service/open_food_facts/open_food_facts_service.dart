import "dart:convert";
import "dart:io";
import "package:http/http.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_api_strings.dart";

class OpenFoodFactsService {
  OpenFoodFactsService._singleton();
  static final OpenFoodFactsService instance = OpenFoodFactsService._singleton();

  late String _apiV1Endpoint;
  late String _apiV2Endpoint;
  // late String _searchALiciousEndPoint;

  late String _appName;
  late String _appVersion;
  late String _appContactMail;
  late bool _useStaging;
  late Future<Response> Function(Uri uri, {Map<String, String>? headers}) _httpGet;

  //httpGet as argument so that it can be mocked for testing
  void init({
    required Future<Response> Function(Uri url, {Map<String, String>? headers}) httpGet,
    required String appName,
    required String appVersion,
    required String appContactMail,
    bool useStaging = false,
  }) {
    _appName = appName;
    _appVersion = appVersion;
    _appContactMail = appContactMail;
    _useStaging = useStaging;
    _httpGet = httpGet;

    String domain = "org";
    if (_useStaging) {
      domain = "net";
    }

    //for text search
    //https://openfoodfacts.github.io/openfoodfacts-server/api/ref-cheatsheet/
    //https://wiki.openfoodfacts.org/API/Read/Search
    _apiV1Endpoint = "https://world.openfoodfacts.$domain/cgi/search.pl?json=1&search_simple=1&";

    //for barcoded search
    //https://openfoodfacts.github.io/openfoodfacts-server/api/
    //https://openfoodfacts.github.io/openfoodfacts-server/api/ref-v2/
    _apiV2Endpoint = "https://world.openfoodfacts.$domain/api/v2/product/";

    //for text search, but not complete yet
    //https://openfoodfacts.github.io/search-a-licious/
    //https://openfoodfacts.github.io/search-a-licious/users/ref-openapi/
    //https://search.openfoodfacts.org/docs/
    // _searchALiciousEndPoint = "https://search.openfoodfacts.$domain/search?";
  }

  Future<String?> getFoodByBarcode({required int barcode}) async {
    Map<String, String> headers = {HttpHeaders.userAgentHeader: "$_appName/$_appVersion ($_appContactMail)"};

    if (_useStaging) {
      headers[HttpHeaders.authorizationHeader] = "Basic ${base64.encode(utf8.encode("off:off"))}";
    }

    Response resp = await _httpGet(
      Uri.parse("$_apiV2Endpoint$barcode?product_type=food&fields=${OpenFoodFactsApiStrings.apiV1V2AllFields.join(",")}"),
      headers: headers,
    );

    //404 means no food with barcode was found, which is still a normal result for us.
    if (resp.statusCode == 200 || resp.statusCode == 404) {
      return resp.body;
    }

    return null;
  }

  Future<String?> getFoodBySearchTextApiV1({required String searchText, required int page, required int pageSize}) async {
    Map<String, String> headers = {HttpHeaders.userAgentHeader: "$_appName/$_appVersion ($_appContactMail)"};

    if (_useStaging) {
      headers[HttpHeaders.authorizationHeader] = "Basic ${base64.encode(utf8.encode("off:off"))}";
    }

    searchText = OpenFoodFactsService._encodeSearchText(searchText);

    //currently requesting specific nutriment fields results in HTTP 500, therefore we request all nutriments, this works.
    Uri uri = Uri.parse(
      "${_apiV1Endpoint}search_terms=$searchText&fields=${OpenFoodFactsApiStrings.apiV1V2AllFieldsAllNutriments.join(",")}&page=$page&page_size=$pageSize",
    );

    Response resp = await _httpGet(uri, headers: headers);

    if (resp.statusCode == 200) {
      return resp.body;
    }

    return null;
  }

  static String _encodeSearchText(String searchText) {
    List<String> searchWords = searchText.split(" ");
    searchWords = searchWords.map((String word) => "'${word.trim()}'").toList();
    searchText = searchWords.join(",");
    searchText = Uri.encodeComponent(searchText);

    return searchText;
  }
}
