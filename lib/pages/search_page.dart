import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchState();
  }
}

class SearchState extends State<SearchPage> {
  List<int> cookingTimes = [];
  TextEditingController ingredientTec = TextEditingController();
  String ingredientPattern = '';
  List<String> allIngredients = [
    'brokul',
    'kalafior'
  ]; //tutaj bym wczytal potem wszystkie skladniki i zrobil wyszukiwarke nie
  List<String> selectedIngredients = ['papryka'];
  int? _chosenTime;
  @override
 
  void initState() {
    for (int i = 0; i < 20; i++) {
      cookingTimes.add((i + 1) * 5);
    }

    ingredientTec.addListener(() {
      setState(() {
        ingredientPattern = ingredientTec.text;
      });
    });
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Wyszukaj danie",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w500)),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            timeSelection(),
            SizedBox(height: 20),
            ingredientsSelection(),
            SizedBox(height: 20),
            chosenIngredients()
          ],
        ));
  }

  Padding timeSelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          height: 100,
          decoration: BoxDecoration(
              border: Border.all(width: 8, color: Colors.black),
              borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Wybierz preferowany czas przygotowania potrawy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              DropdownButton<int>(
                  hint: Text("Pick"),
                  value: _chosenTime,
                  items: cookingTimes.map((int value) {
                    return new DropdownMenuItem<int>(
                      value: value,
                      child: new Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (newVal) {
                    setState(() {
                      _chosenTime = newVal!;
                    });
                  })
            ],
          )),
    );
  }

  Padding ingredientsSelection() {


    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
          height: 200,
          decoration: BoxDecoration(
              border: Border.all(width: 8, color: Colors.black),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                  decoration: InputDecoration(hintText: 'Wyszukaj składniki'),
                  controller: ingredientTec,),
              Container(child: displayIngredients(ingredientPattern), height: 120,)
            ],
          )),
    );
  }

  ListView displayIngredients(String pattern) {
    List<String> ingredients = [];
    if (pattern.isNotEmpty) {
      for (int i = 0; i < allIngredients.length; i++) {
        if (allIngredients[i].contains(pattern)) {
          ingredients.add(allIngredients[i]);
        }
      }
    } else
      {ingredients = allIngredients;}
    return ListView.separated(
        padding: const EdgeInsets.all(8),
        separatorBuilder: (BuildContext context, int Index) => SizedBox(width: 10,),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.black),
                          borderRadius: BorderRadius.circular(12)),
            height: 80,
            width: 160,
            child: Text(ingredients[index], textAlign: TextAlign.center,),
          );
        },
        itemCount: ingredients.length);
  }

  Padding chosenIngredients()
  {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
          height: 200,
          decoration: BoxDecoration(
              border: Border.all(width: 8, color: Colors.black),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Wybrane składniki'),
              Container(child: displayChosenIngredients(), height: 120,)
            ],
          )),
    );
  }

  ListView displayChosenIngredients()
  {
    return ListView.separated(
        padding: const EdgeInsets.all(8),
        separatorBuilder: (BuildContext context, int Index) => SizedBox(width: 10,),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.black),
                          borderRadius: BorderRadius.circular(12)),
            height: 80,
            width: 160,
            child: Text(selectedIngredients[index], textAlign: TextAlign.center,),
          );
        },
        itemCount: selectedIngredients.length);
  }


}
