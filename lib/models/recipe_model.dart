class Recipe {
  final int id;
  final int minutes;
  final String name;
  final String nutrition;
  final String steps;
  List<String> stepsList = [];

  Recipe({
    required this.id,
    required this.name,
    required this.minutes,
    required this.nutrition,
    required this.steps,
  })
  
  {
    
    if(steps.isNotEmpty)
    {
      stepsList = steps.split(", ");
      for(int i=0; i<stepsList.length; i++)
      {
        stepsList[i] = stepsList[i].replaceAll('[', '').replaceAll(']', '').replaceAll('\'', '').trim();
      }
    }

  }
}