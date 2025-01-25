import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';
import 'package:szef_kuchni_v2/services/database_service.dart';
import 'package:szef_kuchni_v2/views/all_recipes_view.dart';
import 'package:szef_kuchni_v2/views/recipe_view.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'recipe_view_test.mocks.dart';

@GenerateMocks([stt.SpeechToText, FlutterTts, DatabaseService])
void main()
{
  late MockDatabaseService mockDatabaseService;
  late Recipe testRecipe;
  late Recipe testRecipe2;

  setUp(()
  {
    mockDatabaseService = MockDatabaseService();

    testRecipe = Recipe(id: 1, name: "Mock recipe", minutes: 45, nutrition: "[300, 1, 1, 1, 1, 1, 1]", steps: "['step 1', 'step 2', 'step 3 with a ,']", isFavourite: false);
    testRecipe2 = Recipe(id: 2, name: "Mock2 recipe ", minutes: 75, nutrition: "[300, 1, 1, 1, 1, 1, 1]", steps: "['step 1', 'step 2']", isFavourite: false);
  });
  group("Testing the UI", (){
    testWidgets("Display ingredients", (WidgetTester tester) async {

        when(mockDatabaseService.getRecipeNames(batchNumber: 0, batchSize: 40, minTime: 0, maxTime: 0, selectedIngredients: [], selectedCategories: [])).thenAnswer(
    (_) async => [testRecipe, testRecipe2], );
    
      when(mockDatabaseService.getIngredientsNames()).thenAnswer((_) async => ['tomato', 'potato']);
      when(mockDatabaseService.getCategoriesNames()).thenAnswer((_) async => ['vegan', 'high protein']);

        await tester.pumpWidget(MaterialApp(home: AllRecipesView(onSignalReceived: (String signal){}, dbs: mockDatabaseService,)));
        await tester.pump();
        await tester.pump(Duration(seconds: 2));
        //await tester.pumpAndSettle();
        expect(find.textContaining('Mock recipe'), findsOneWidget);
        expect(find.textContaining('Mock2 recipe'), findsOneWidget);
    });

    testWidgets("opening a recipe", (WidgetTester tester) async {when(mockDatabaseService.getRecipeNames(batchNumber: 0, batchSize: 40, minTime: 0, maxTime: 0, selectedIngredients: [], selectedCategories: [])).thenAnswer(
    (_) async => [testRecipe, testRecipe2], );
    
      when(mockDatabaseService.getIngredientsNames()).thenAnswer((_) async => ['tomato', 'potato']);
      when(mockDatabaseService.getCategoriesNames()).thenAnswer((_) async => ['vegan', 'high protein']);

        await tester.pumpWidget(MaterialApp(home: AllRecipesView(onSignalReceived: (String signal){}, dbs: mockDatabaseService,)));
        await tester.pump();
        await tester.pump(Duration(seconds: 2));

        final recipeButton = find.bySemanticsLabel('Mock recipe');
        await tester.tap(recipeButton);
        await tester.pump();
        await tester.pump(Duration(seconds: 2));
        expect(find.byType(RecipeView), findsOneWidget);

    });
    
  });


  
}