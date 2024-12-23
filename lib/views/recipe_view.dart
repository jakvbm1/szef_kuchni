import 'package:flutter/material.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';
import 'package:szef_kuchni_v2/services/database_service.dart';
import 'package:szef_kuchni_v2/services/save_and_open_pdf.dart';
import 'package:szef_kuchni_v2/services/simple_pdf_api.dart';

class RecipeView extends StatefulWidget {
  final Recipe recipe;

  const RecipeView({super.key, required this.recipe});

  @override
  State<RecipeView> createState() => _RecipeViewState(recipe: recipe);
}

class _RecipeViewState extends State<RecipeView> {
  _RecipeViewState({required this.recipe});
  Recipe recipe;
  List<String> ingredients = [];
  bool ingredientsLoaded = false;
  @override
  void initState() {
    setState(() {
      _loadIngredientsNames();
    });
    super.initState();
  }

  Future<void> _loadIngredientsNames() async {
    ingredients = await DatabaseService().getRecipeIngredients(recipe.id);
    setState(() {
      ingredientsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: recipeAppBar(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            foodStats(),
            ingredientsDisplay(),
            Expanded(child: stepsList())
          ],
        ));
  }

  AppBar recipeAppBar(BuildContext context) {
    return AppBar(title: Text(widget.recipe.name), actions: <Widget>[
      // pdf file creation
      IconButton(
        onPressed: () async {
          final simplePdfFile = await SimplePdfApi.generateSimpleTextPdf(
            recipe.name,
            recipe.minutes.toString(),
          );
          SaveAndOpenPdf.openPdf(simplePdfFile);
        },
        icon: const Icon(Icons.picture_as_pdf),
      ),
      IconButton(
        icon: Icon(Icons.thumb_up,
            color: recipe.isFavourite ? Colors.blueAccent : Colors.black),
        onPressed: () {
          setState(() {
            recipe.changeFavourite();
          });

          String displayedText;
          if (recipe.isFavourite) {
            displayedText = 'added to favourites!';
          } else {
            displayedText = 'removed from favourites!';
          }

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(displayedText)));
        },
      ),
    ]);
  }

  Padding foodStats() {
    List<String> nutrients = widget.recipe.nutrition
        .replaceAll('[', '')
        .replaceAll(']', '')
        .trim()
        .split(", ");

    String time;
    if (widget.recipe.minutes < 60) {
      time = '${widget.recipe.minutes} min';
    } else {
      time = "${widget.recipe.minutes ~/ 60}h ";
      if (widget.recipe.minutes % 60 != 0) {
        time += "${widget.recipe.minutes % 60}min";
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: Colors.indigo[200]),
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
            ),
            //to likely cos jest pojebane
            Text(
              "${nutrients[0]} kcal | ${nutrients[1]}g total fat | of which saturated ${nutrients[5]}g |" +
                  "${nutrients[2]}g sodium | ${nutrients[3]}g protein | ${nutrients[6]}g carbohydrates",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Padding ingredientsDisplay() {
    if (ingredientsLoaded) {
      String ingr = '';

      for (int i = 0; i < ingredients.length; i++) {
        if (i == ingredients.length - 1) {
          ingr += "${ingredients[i]}";
        } else {
          ingr += "${ingredients[i]},  ";
        }
      }
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.indigo[200]),
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                Text(
                  ingr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ],
            )),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.indigo[200]),
            height: 150,
            child: Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )),
      );
    }
  }

  ListView stepsList() {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 10),
      itemCount: widget.recipe.stepsList.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.indigo[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.recipe.stepsList[index],
              textAlign: TextAlign.center,
              style: const TextStyle(
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
