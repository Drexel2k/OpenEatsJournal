import 'package:flutter/material.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/main_layout.dart';
import 'package:openeatsjournal/ui/utils/open_eats_journal_strings.dart';

class FoodEditScreen extends StatelessWidget {
  const FoodEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteFoodEdit,
      title: AppLocalizations.of(context)!.edit_food,
      body: SizedBox()
    );
  }
}
