import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';
import 'package:szef_kuchni_v2/services/database_service.dart';
import 'package:szef_kuchni_v2/services/save_and_open_pdf.dart';
import 'package:szef_kuchni_v2/services/recipe_pdf_api.dart';

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
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.secondaryContainer,
        appBar: recipeAppBar(context, theme),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child:Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container
              (
                decoration: BoxDecoration
                (
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Column
                (
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: 
                  [
                    foodStats(theme),
                    ingredientsDisplay(theme),
                  ],
                ),
              ),
            )),
            Expanded(child: stepsList(theme))
          ],
        ));
  }

  AppBar recipeAppBar(BuildContext context, ThemeData theme) {
    return AppBar(title: Text(widget.recipe.name),
     backgroundColor: theme.colorScheme.surfaceContainerHigh,
      actions: <Widget>[
      // pdf file creation
      IconButton(
        onPressed: () async {
          final simplePdfFile = await RecipePdfApi.generateRecipePdf(recipe, ingredients);
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

  Padding foodStats(ThemeData theme) {
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
            borderRadius: BorderRadius.circular(12), color: theme.colorScheme.surface),
        height: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AutoSizeText(
              time,
              maxFontSize: 24,
              minFontSize: 20,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
            ),
            //to likely cos jest pojebane
            AutoSizeText(
              "${nutrients[0]} kcal | ${nutrients[1]}g total fat | of which saturated ${nutrients[5]}g |" +
                  "${nutrients[2]}g sodium | ${nutrients[3]}g protein | ${nutrients[6]}g carbohydrates",
              textAlign: TextAlign.center,
              maxFontSize: 18,
              minFontSize: 12,
              style: const TextStyle( fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Padding ingredientsDisplay(ThemeData theme) {
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
                color: theme.colorScheme.surface),
            height: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const AutoSizeText(
                  'Ingredients',
                  maxFontSize: 22,
                  minFontSize: 16,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                AutoSizeText(
                  ingr,
                  maxFontSize: 14,
                  minFontSize: 10,
                  style: const TextStyle(fontWeight: FontWeight.w400),
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

  ListView stepsList(ThemeData theme) {
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
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              
            ),
            alignment: Alignment.center,
            child: AutoSizeText(
              maxFontSize: 14,
              minFontSize: 10,
              widget.recipe.stepsList[index],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
