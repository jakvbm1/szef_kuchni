import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';
import 'package:szef_kuchni_v2/services/database_service.dart';
import 'package:szef_kuchni_v2/views/main_view.dart';
import 'package:szef_kuchni_v2/views/all_recipes_view.dart';
import 'package:szef_kuchni_v2/views/favourite_recipes.dart';
import 'package:szef_kuchni_v2/views/recipe_view.dart';
import 'package:szef_kuchni_v2/views/search_recipes.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

@GenerateMocks([stt.SpeechToText, FlutterTts, DatabaseService])
void main()
{
  late Recipe testRecipe;

  setUp(()
  {
    testRecipe = Recipe(id: 1, name: "Mock recipe", minutes: 45, nutrition: "[300, 1, 1, 1, 1, 1, 1]", steps: "['step 1', 'step 2', 'step 3 with a ,']", isFavourite: false);
  });
  group("Testing the UI", (){
    testWidgets("Displaying recipe's name in the appBar", (WidgetTester tester) async
  {
    await tester.pumpWidget(MaterialApp(home: RecipeView(recipe: testRecipe)));
    expect(find.text(testRecipe.name), findsOneWidget);
  });  

    testWidgets("Displaying recipe's nutrition", (WidgetTester tester) async
    {
      await tester.pumpWidget(MaterialApp(home: RecipeView(recipe: testRecipe)));
      expect(find.text("${300.0} kcal\n ${1.0}g total fat | of which saturated ${1.0}g\n ${1.0}g carbohydrates | of which sugar ${1.0}g\n ${1.0}g protein | ${1.0}g sodium"), findsOne);
                
                
    });

  });

  testWidgets("displaying steps", (WidgetTester tester) async 
  {
          await tester.pumpWidget(MaterialApp(home: RecipeView(recipe: testRecipe)));
          expect(find.text('step 1'), findsOneWidget);
          expect(find.text('step 2'), findsOneWidget);
          expect(find.text('step 3 with a ,'), findsOneWidget);
  });


  
}