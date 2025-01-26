import 'package:flutter/material.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';
import 'package:szef_kuchni_v2/services/database_service.dart';
import 'package:szef_kuchni_v2/views/recipe_view.dart';

class FavouriteRecipesView extends StatefulWidget{
  FavouriteRecipesView({DatabaseService? dbs, super.key}) : dbService = dbs ?? DatabaseService();
  final DatabaseService dbService;
  @override
  State<FavouriteRecipesView> createState() => _FavouriteRecipesViewState(databaseService: dbService);
}

class _FavouriteRecipesViewState extends State<FavouriteRecipesView> {

  bool loaded = false;
  List<Recipe> recipe = [];
  final DatabaseService databaseService;

  _FavouriteRecipesViewState({required this.databaseService});
  
  @override
  void initState() {
    setState(() {
      loadRecipes();
    });
    super.initState();
  }

  Future<void> loadRecipes() async
  {
    recipe = await databaseService.getFavRecipes();
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
    var theme = Theme.of(context);
    
    return Scaffold
    (
      backgroundColor: theme.colorScheme.secondaryContainer,

      appBar: AppBar(title: Text("Ulubione potrawy", style: TextStyle(fontWeight: FontWeight.w500),), backgroundColor: theme.colorScheme.surfaceContainerHigh,),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration
          (
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surfaceContainerHigh
          ),
          child: recipesDisplay(context)),
      ) ,
    );
  }

  Column recipesDisplay(BuildContext context)
  
  {
    var theme = Theme.of(context);

    if(!loaded)
    {
      return Column
      (
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [Container(height: 100, child: Text("Loading..."),)],
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
             separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 4,),
              itemCount: recipe.length,
              itemBuilder:(BuildContext context, int index) {return Padding
              (padding: const EdgeInsets.all(8),
               child: GestureDetector
               (
  onTap: () async {
    // Navigate to RecipeView and wait for the result
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RecipeView(recipe: recipe[index]),
  ),
).then((_) {
  setState(() {
    loaded = false;
    loadRecipes();
  });
});

  },

                child: Container
                (
                  height: 80,
                  alignment: Alignment.center,
                  child: Text(recipe[index].name, style: TextStyle(fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  decoration: BoxDecoration
                  (
                    borderRadius: BorderRadius.circular(12),
                    color: theme.canvasColor
                  ),
                ),
               ),);}),
          )
        ],
      );
    }
  }

}