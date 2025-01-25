import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import 'package:szef_kuchni_v2/views/main_view.dart';
import 'package:szef_kuchni_v2/views/all_recipes_view.dart';
import 'package:szef_kuchni_v2/views/favourite_recipes.dart';
import 'package:szef_kuchni_v2/views/search_recipes.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


@GenerateMocks([stt.SpeechToText])


void main() {

  setUp(() {
  });

  Widget createMainView() {
    return MaterialApp(
      home: MainView(
        onThemeChanged: (bool isDarkMode) {},
      ),
    );
  }

  group('MainView Widget Tests', () {
    testWidgets('renders AllRecipesView by default', (tester) async {
      await tester.pumpWidget(createMainView());

      // Expect AllRecipesView is rendered
      expect(find.byType(AllRecipesView), findsOneWidget);
    });

    testWidgets('switches to FavouriteRecipesView when the favorites icon is tapped', (tester) async {
      await tester.pumpWidget(createMainView());

      // Tap the favorites icon
      final favoriteIcon = find.byIcon(Icons.favorite);
      await tester.tap(favoriteIcon);
      await tester.pumpAndSettle();

      // Expect FavouriteRecipesView is rendered
      expect(find.byType(FavouriteRecipesView), findsOneWidget);
    });

    testWidgets('switches to SearchRecipesView when the search icon is tapped', (tester) async {
      await tester.pumpWidget(createMainView());

      // Tap the search icon
      final searchIcon = find.byKey(Key("ToggleSearch"));
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();

      // Expect SearchRecipesView is rendered
      expect(find.byType(SearchRecipesView), findsOneWidget);
    });

    testWidgets('toggles dark mode when switch is toggled', (tester) async {
      bool isDarkMode = false;

      await tester.pumpWidget(MaterialApp(
        home: MainView(
          onThemeChanged: (bool value) {
            isDarkMode = value;
          },
        ),
      ));

      // Find the toggle switch
      final switchFinder = find.byType(Switch);
      expect(isDarkMode, isFalse);

      // Toggle the switch
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Expect dark mode to be enabled
      expect(isDarkMode, isTrue);
    });



  });
}
