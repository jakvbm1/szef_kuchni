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
    return Scaffold
    (
      body: Expanded(child: recipesDisplay()) ,
    );
  }

  Column recipesDisplay()
  {
    if(!loaded)
    {
      return Column
      (
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [Placeholder()],
      );
    }

    else
    {
      return Column
      (
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: 
        [
          Expanded(
            child: ListView.separated
            (
             separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10,),
              itemCount: recipe.length,
              itemBuilder:(BuildContext context, int index) {return Padding
              (padding: const EdgeInsets.all(8),
               child: GestureDetector
               (
                onTap: (){},
                child: Container
                (
                  height: 100,
                  child: Text(recipe[index].name),
                ),
               ),);}),
          )
        ],
      );
    }
  }

}