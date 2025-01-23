import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';
import 'package:szef_kuchni_v2/services/database_service.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'dart:io';

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Recipe Model Tests', () {
    test('StepsList should parse steps correctly', () {
      final recipe = Recipe(
        id: 1,
        name: 'Test Recipe',
        minutes: 30,
        nutrition: '200, 10, 2, 4, 7, 5, 1',
        steps: "['Step 1', 'Step 2', 'Step 3']",
        isFavourite: false,
      );

      expect(recipe.stepsList.length, 3);
      expect(recipe.stepsList, ['Step 1', 'Step 2', 'Step 3']);
    });
  }
  );
}
