import 'package:flutter/material.dart';

class SearchRecipesView extends StatelessWidget{
  const SearchRecipesView({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.secondaryContainer,
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              "Wyszukaj po nazwie",
              style: TextStyle(
                fontSize: 24,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            )
            
          ],
        ),
      ),
    );
  }
}