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
import 'recipe_view_test.mocks.dart';

@GenerateMocks([stt.SpeechToText, FlutterTts, DatabaseService])
void main()
{
  late MockDatabaseService mockDatabaseService;
  late MockSpeechToText mockSpeechToText;
  late MockFlutterTts mockFlutterTts;
  late Recipe testRecipe;

  setUp(()
  {
    mockDatabaseService = MockDatabaseService();
    mockSpeechToText = MockSpeechToText();
    mockFlutterTts = MockFlutterTts();
    testRecipe = Recipe(id: 1, name: "Mock recipe", minutes: 45, nutrition: "[300, 1, 1, 1, 1, 1, 1]", steps: "['step 1', 'step 2', 'step 3 with a ,']", isFavourite: false);
  });
  group("Testing the UI", (){
    testWidgets("Displaying recipe's name in the appBar", (WidgetTester tester) async
  {
    await tester.pumpWidget(MaterialApp(home: RecipeView(recipe: testRecipe)));
    expect(find.text(testRecipe.name), findsOneWidget);
  });  

  testWidgets("Display time test", (WidgetTester tester) async 
  {
    await tester.pumpWidget(MaterialApp(home: RecipeView(recipe: testRecipe)));
    expect(find.textContaining('45 min'), findsOneWidget);
  });

    testWidgets("Display macro test", (WidgetTester tester) async 
  {
    await tester.pumpWidget(MaterialApp(home: RecipeView(recipe: testRecipe)));
    expect(find.textContaining('300 kcal'), findsOneWidget);
    expect(find.textContaining('1g carbohydrates'), findsOneWidget);
  });

  });

  testWidgets("displaying steps", (WidgetTester tester) async 
  {
          await tester.pumpWidget(MaterialApp(home: RecipeView(recipe: testRecipe)));
          expect(find.text('step 1'), findsOneWidget);
          expect(find.text('step 2'), findsOneWidget);
          expect(find.text('step 3 with a ,'), findsOneWidget);
  });

  group("Database connection tests", (){
  testWidgets('testing changing favourites', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
    home: RecipeView(recipe: testRecipe),
      ));

    expect(testRecipe.isFavourite, false);

    final favoriteButton = find.byIcon(Icons.thumb_up);
    await tester.tap(favoriteButton);
    expect(testRecipe.isFavourite, true);
    await tester.tap(favoriteButton);
    expect(testRecipe.isFavourite, false);
});

testWidgets('loading and displaying ingredients', (WidgetTester tester) async {
  // Mock the DatabaseService
  final mockDatabaseService = MockDatabaseService();
  when(mockDatabaseService.getRecipeIngredients(any)).thenAnswer(
    (_) async => ['Salt', 'Pepper'],
  );

  // Inject mock service into RecipeView
  await tester.pumpWidget(MaterialApp(
    home: RecipeView(
      recipe: testRecipe,
      dbService: mockDatabaseService,
    ),
  ));

  // Wait for the Future to resolve and the UI to rebuild
  await tester.pump();
  await tester.pumpAndSettle();
  // Verify ingredients are displayed
  expect(find.textContaining('Ingredients'), findsOneWidget); // Adjust text if necessary
  expect(find.textContaining('Salt'), findsOneWidget);
  expect(find.textContaining('Pepper'), findsOneWidget);
});



  });


  
}