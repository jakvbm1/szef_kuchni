import 'package:szef_kuchni_v2/services/database_service.dart';

class Recipe {
  final int id;
  final int minutes;
  final String name;
  final String nutrition;
  final String steps;
  bool isFavourite;
  List<String> stepsList = [];

  Recipe({
    required this.id,
    required this.name,
    required this.minutes,
    required this.nutrition,
    required this.steps,
    required this.isFavourite,
  }) {
    if(steps.isNotEmpty)
    {
      stepsList = steps.split(", ");
      for(int i=0; i<stepsList.length; i++)
      {
        stepsList[i] = stepsList[i].replaceAll('[', '').replaceAll(']', '').replaceAll('\'', '').trim();
      }
    }
  }

  void changeFavourite() {

    if(isFavourite)
    {
      DatabaseService().remRecipeFromFavourites(this.id);
    }

    else
    {
      DatabaseService().addRecipeToFavourites(this.id);
    }

    isFavourite = !isFavourite;
    print(isFavourite);
    // update the database
  }
}
