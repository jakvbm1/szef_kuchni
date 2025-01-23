import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';
import 'package:szef_kuchni_v2/services/database_service.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'dart:io';
import 'package:szef_kuchni_v2/services/recipe_pdf_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Initialize the binding

  group('PDF Generation Tests', () {
    test('PDF generates correctly', () async {
      final recipe = Recipe(
        id: 1,
        name: 'Test Recipe',
        minutes: 30,
        nutrition: '200, 100, 1, 1, 1, 1, 1',
        steps: "['Step 1', 'Step 2']",
        isFavourite: false,
      );
      final ingredients = ['Ingredient 1', 'Ingredient 2'];

      // Inaczej wywala o tym ze font nie wspiera unicode a idk czy nas to obchodzi
      pdf.Document.debug = false;

      final pdfFile = await RecipePdfApi.generateRecipePdf(recipe, ingredients);

      expect(pdfFile, isA<File>());
      expect(await pdfFile.exists(), true);
    });
  });
}
