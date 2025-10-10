import "dart:convert";
import "dart:io";

import "package:http/http.dart" as http;
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

  void init({required String appName, required String appVersion, required String appContactMail, bool useStaging = false}) {
    _appName = appName;
    _appVersion = appVersion;
    _appContactMail = appContactMail;
    _useStaging = useStaging;

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
    _apiV2Endpoint = "https://world.openfoodfacts.$domain/api/v2/product/?";

    //for text search, but not complete yet
    //https://openfoodfacts.github.io/search-a-licious/
    //https://openfoodfacts.github.io/search-a-licious/users/ref-openapi/
    //https://search.openfoodfacts.org/docs/
    // _searchALiciousEndPoint = "https://search.openfoodfacts.$domain/search?";
  }

  Future<String?> getFoodByBarcode({required String barcode}) async {
    Map<String, String> headers = {HttpHeaders.userAgentHeader: "$_appName/$_appVersion ($_appContactMail)"};

    if (_useStaging) {
      headers[HttpHeaders.authorizationHeader] = "Basic ${base64.encode(utf8.encode("off:off"))}";
    }

    barcode = OpenFoodFactsService._encodeSearchText(barcode);
    Response resp = await http.get(
      Uri.parse("$_apiV2Endpoint${barcode}product_type=food&fields=${OpenFoodFactsApiStrings.apiV1V2AllFields.join(",")}"),
      headers: headers,
    );

    if (resp.statusCode == 200) {
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
    Uri uri = Uri.parse(
      "${_apiV1Endpoint}search_terms=$searchText&fields=${OpenFoodFactsApiStrings.apiV1V2AllFields.join(",")}&page=$page&page_size=$pageSize",
    );

    Response resp = await http.get(uri, headers: headers);

    if (resp.statusCode == 200) {
      return resp.body;
    }

    return null;
  }

  // Future<String?> getFoodBySearchTextSearchALicous({required String searchText, required String languageCode, required int page}) async {
  //   Map<String, String> headers = {
  //     HttpHeaders.userAgentHeader: "$_appName/$_appVersion ($_appContactMail)",
  //     HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
  //   };

  //   if (_useStaging) {
  //     headers[HttpHeaders.authorizationHeader] = "Basic ${base64.encode(utf8.encode("off:off"))}";
  //   }

  //   String languageCodes = OpenEatsJournalStrings.en;
  //   if (languageCode != OpenEatsJournalStrings.en) {
  //     languageCodes = "$languageCode,$languageCodes";
  //   }

  //   searchText = OpenFoodFactsService._encodeSearchText(searchText);
  //   //Uri uri = Uri.parse("${_textSearchEndpoint}q=$searchText&fields=${OpenFoodFactsApiStrings.searchALiciousAllFields.join(",")}&langs=$languageCodes&page_size=100&page=$page");
  //   Uri uri = Uri.parse("${_searchALiciousEndPoint}q=$searchText&langs=$languageCodes&page_size=100&page=$page");
  //   Response resp = await http.get(uri);

  //   if (resp.statusCode == 200) {
  //     return resp.body;
  //   }

  //   return null;
  // }

  static String _encodeSearchText(String searchText) {
    List<String> searchWords = searchText.split(" ");
    searchWords = searchWords.map((word) => "'$word'").toList();
    searchText = searchWords.join(",");
    searchText = Uri.encodeComponent(searchText);

    return searchText;
  }
}
