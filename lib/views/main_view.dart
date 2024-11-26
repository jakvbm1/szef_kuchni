import 'package:flutter/material.dart';
import 'package:szef_kuchni_v2/views/all_recipes_view.dart';
import 'package:szef_kuchni_v2/views/favourite_recipes.dart';
import 'package:szef_kuchni_v2/views/search_recipes.dart';


class MainView extends StatefulWidget {
  const MainView({super.key});
  
  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontSize: 35.0,
      fontWeight: FontWeight.w900,
    );
    
    Widget view;
    switch (selectedIndex) {
      case 0:
        view = const AllRecipesView();
      case 1:
        view = const SearchRecipesView();
      case 2:
        view = const FavouriteRecipesView();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: view,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        titleSpacing: 20.0,
        title: Row(
          children: [
            Expanded(
              child: Card(
                color: theme.cardTheme.color,
                child: Padding(
                  padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                  child: Text(
                    "Szef Kuchni", 
                    style: style,
                    textAlign: TextAlign.center,
                  ),
                )
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
