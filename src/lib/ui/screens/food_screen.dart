import "dart:async";

import "package:flutter/material.dart";
import "package:openeatsjournal/domain/food.dart";

import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/food_viewmodel.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:openeatsjournal/ui/utils/navigator_routes.dart";
import "package:openeatsjournal/ui/utils/oej_strings.dart";
import "package:openeatsjournal/ui/widgets/oej_textfield.dart";

class FoodScreen extends StatelessWidget {
  FoodScreen({super.key, required FoodViewModel foodViewModel})
    : _foodViewModel = foodViewModel,
      _searchTextController = TextEditingController();

  final FoodViewModel _foodViewModel;
  final TextEditingController _searchTextController;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;

    return MainLayout(
      route: NavigatorRoutes.food,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OejTextField(controller: _searchTextController, hintText: "Search food..."),
              ),
              SizedBox(width: 5),
              OutlinedButton(
                onPressed: () async {
                  try {
                    await _search(languageCode: languageCode);
                  } on Exception catch (exc, stack) {
                    await ErrorHandlers.showException(
                      context: navigatorKey.currentContext!,
                      exception: exc,
                      stackTrace: stack,
                    );
                  } on Error catch (error, stack) {
                    await ErrorHandlers.showException(
                      context: navigatorKey.currentContext!,
                      error: error,
                      stackTrace: stack,
                    );
                  }
                },
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
                  try {
                    Object? barcodeScanResult = await Navigator.pushNamed(context, NavigatorRoutes.barcodeScanner);
                    if (barcodeScanResult != null) {
                      String barcode = barcodeScanResult as String;
                      _searchTextController.text = "code:$barcode";
                      await _search(languageCode: languageCode);
                    }
                  } on Exception catch (exc, stack) {
                    await ErrorHandlers.showException(
                      context: navigatorKey.currentContext!,
                      exception: exc,
                      stackTrace: stack,
                    );
                  } on Error catch (error, stack) {
                    await ErrorHandlers.showException(
                      context: navigatorKey.currentContext!,
                      error: error,
                      stackTrace: stack,
                    );
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
          SizedBox(height: 8),

          ListenableBuilder(
            listenable: _foodViewModel.foodSearchResultChangedNotifier,
            builder: (contextBuilder, _) {
              return Expanded(
                child: ListView.builder(
                  itemCount: _foodViewModel.foodSearchResult.length,
                  itemBuilder: (context, index) {
                    return Card(child: Text(_foodViewModel.foodSearchResult[index].name));
                  },
                ),
              );
            },
          ),
        ],
      ),
      title: AppLocalizations.of(context)!.food_management,
    );
  }

  Future<void> _search({required String languageCode}) async {
    String cleanSearchText = _searchTextController.text.trim();
    if (cleanSearchText != OejStrings.emptyString) {
      List<String> parts = cleanSearchText.split(":");

      if (parts.length == 2 && parts[0].toLowerCase() == "code") {
        Food? food = await _foodViewModel.getFoodByBarcode(barcode: parts[1], languageCode: languageCode);
        if (food != null) {
          _foodViewModel.setNewSearchResult([food]);
        }
      } else {
        List<Food>? foods = await _foodViewModel.getFoodBySearchText(
          searchText: cleanSearchText,
          languageCode: languageCode,
        );

        if (foods != null) {
          _foodViewModel.setNewSearchResult(foods);
        }
      }
    }
  }
}
