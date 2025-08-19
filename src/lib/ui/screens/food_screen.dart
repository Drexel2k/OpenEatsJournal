import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:http/http.dart";
import "package:http/http.dart" as http;
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/food_viewmodel.dart";
import "package:openeatsjournal/ui/utils/navigator_routes.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";

class FoodScreen extends StatelessWidget {
  FoodScreen({super.key, required FoodViewModel foodViewModel})
    : _foodViewModel = foodViewModel,
      _searchTextController = TextEditingController();

  final FoodViewModel _foodViewModel;
  final TextEditingController _searchTextController;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      route: NavigatorRoutes.food,
      body: Column(
        children: [
          Row(
            children: [
              SettingsTextField(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: CircleBorder(),
                  minimumSize: Size(40, 40),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Icon(Icons.search),
              ),
              SizedBox(width: 5),
              OutlinedButton(
                onPressed: () async {
                  final Object? barcodeScanResult = await Navigator.pushNamed(context, NavigatorRoutes.barcodeScanner);
                  if (barcodeScanResult != null) {
                    String barcode = barcodeScanResult as String;
                    Response resp = await http.get(
                      Uri.parse("https://world.openfoodfacts.net/api/v2/product/3274080005003.json"),
                      headers: {
                        HttpHeaders.authorizationHeader: "Basic ${base64.encode(utf8.encode("off:off"))}",
                        HttpHeaders.userAgentHeader: "${_foodViewModel.appName}/${_foodViewModel.appVersion} (${_foodViewModel.appContactMail})",
                      },
                    );
                    if (resp.statusCode == 200) {
                      // If the server did return a 200 OK response,
                      // then parse the JSON.
                      var body = resp.body;
                      print(body);
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: CircleBorder(),
                  minimumSize: Size(40, 40),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Icon(Icons.qr_code_scanner),
              ),
            ],
          ),
        ],
      ),
      title: AppLocalizations.of(context)!.food_management,
    );
  }
}
