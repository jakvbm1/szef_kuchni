class Recipe {
  final int id;
  final int minutes;
  final String name;
  final String nutrition;
  final String steps;
  final bool isFavourite;

  Recipe({
    required this.id,
    required this.name,
    required this.minutes,
    required this.nutrition,
    required this.steps,
    required this.isFavourite,
  });
}
