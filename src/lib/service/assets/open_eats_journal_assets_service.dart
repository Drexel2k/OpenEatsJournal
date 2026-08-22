import "package:csv/csv.dart";
import "package:flutter/services.dart";

class OpenEatsJournalAssetsService {
  Future<List<String>> getStandardFoodFiles() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return assetManifest.listAssets().where((string) => string.startsWith("assets/standard_food_data")).toList();
  }

  Future<List<List<String>>> getCsvContent({required String path}) async {
    //assets can't be streamed, the entire file need to be loaded into memory, so we have to split the data file in chunks to don't escalate memory usage one
    //large files: https://github.com/flutter/flutter/issues/73322

    return csv.decode(await rootBundle.loadString(path)).map<List<String>>((first) => first.map<String>((second) => second as String).toList()).toList();
  }
}
