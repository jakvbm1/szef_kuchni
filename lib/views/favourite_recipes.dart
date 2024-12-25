import 'package:flutter/material.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';
import 'package:szef_kuchni_v2/services/database_service.dart';

class FavouriteRecipesView extends StatefulWidget{
  const FavouriteRecipesView({super.key});

  @override
  State<FavouriteRecipesView> createState() => _FavouriteRecipesViewState();
}

class _FavouriteRecipesViewState extends State<FavouriteRecipesView> {

  bool loaded = false;
  List<Recipe> recipe = [];
  
  @override
  void initState() {
    setState(() {
      loadRecipes();
    });
    super.initState();
  }

  Future<void> loadRecipes() async
  {
    recipe = await DatabaseService().getFavRecipes();
    for(int i=0; i<recipe.length; i++)
    {
      print(recipe[i].name);
    }
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

}