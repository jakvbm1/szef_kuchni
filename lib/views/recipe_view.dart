import 'package:flutter/material.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';

class RecipeView extends StatefulWidget
{
  
  Recipe recipe;

  RecipeView({required this.recipe});

  @override
  State<RecipeView> createState() => _RecipeViewState(recipe: recipe);
}

class _RecipeViewState extends State<RecipeView> {

  Recipe recipe;
  _RecipeViewState({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      appBar: recipeAppBar(context),
      body: Column
      (
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          foodStats(),
          Expanded(child: stepsList())
        ],
      )
    );
    
  }

  AppBar recipeAppBar(BuildContext context) {
    return AppBar
    (
      title: Text(
        widget.recipe.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.thumb_up, color: recipe.favourite?Colors.blueAccent:Colors.black),
            onPressed: (){
              setState(() {
                recipe.changeFavourite();
              });

              String displayedText;
              if(recipe.favourite) {displayedText = 'added to favourites!';}
              else {displayedText = 'removed from favourites!';}

              ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(displayedText)));
              },
            ),
             
        ]
    

    );
  }

  Padding foodStats()
  {
    List<String> nutrients = widget.recipe.nutrition.replaceAll('[', '').replaceAll(']', '').trim().split(", ");

    String time;
    if(widget.recipe.minutes < 60){time = widget.recipe.minutes.toString() + ' min';}
    else
    {
      time = "${(widget.recipe.minutes / 60).toInt()}h ";
      if (widget.recipe.minutes % 60 != 0)
      {
        time += "${widget.recipe.minutes % 60}min";
      }
    }

    return Padding
    (padding: const EdgeInsets.all(8),
    child: Container
    (
      decoration: BoxDecoration
      (
        borderRadius: BorderRadius.circular(12),
        color: Colors.indigo[200]
      ),
      height: 300,

      child: Column
      (
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,

        children: 
        [
          Text(time, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),),
          //to likely cos jest pojebane
          Text("${nutrients[0]} kcal | ${nutrients[1]}g total fat | of which saturated ${nutrients[5]}g |" + 
           "${nutrients[2]}g sodium | ${nutrients[3]}g protein | ${nutrients[6]}g carbohydrates",
           textAlign: TextAlign.center,
           style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),),

        ],
      ),

    ),
    );
  }

 ListView stepsList()
 {
  return ListView.separated(

    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
    itemCount: widget.recipe.stepsList.length,
    scrollDirection: Axis.vertical,
    itemBuilder: (BuildContext context, int index)
    {
      return 
        

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 80,
            
              decoration: BoxDecoration
              (
                color: Colors.indigo[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text
              (
                widget.recipe.stepsList[index],
                textAlign: TextAlign.center,
                style: const TextStyle
                (
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );


      
    },
      );
 }
}