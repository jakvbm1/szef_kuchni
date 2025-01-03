import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';
import 'package:szef_kuchni_v2/services/save_and_open_pdf.dart';

class RecipePdfApi {
  static Future<File> generateRecipePdf(
      Recipe recipe, List<String> ingredients) async {
    final pdf = Document();

    pdf.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          buildHeader(recipe),
          SizedBox(height: 20),
          buildIngredientsSection(recipe, ingredients),
          SizedBox(height: 20),
          buildStepsSection(recipe),
        ],
      ),
    );

    return SaveAndOpenPdf.savePdf(
      name: 'recipe_${recipe.name.replaceAll(' ', '_')}.pdf',
      pdf: pdf,
    );
  }

  static Widget buildHeader(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Preparation Time: ${recipe.minutes} minutes',
          style: const TextStyle(fontSize: 16, color: PdfColors.grey700),
        ),
        Divider(thickness: 1, color: PdfColors.grey400),
      ],
    );
  }

  static Widget buildIngredientsSection(
      Recipe recipe, List<String> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...ingredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '- $ingredient',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }),
      ],
    );
  }

  static Widget buildStepsSection(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Steps',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...recipe.stepsList.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              '${index + 1}. $step',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }),
      ],
    );
  }
}
