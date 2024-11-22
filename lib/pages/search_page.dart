import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

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

  List<String> allCharacteristics = ['smaczne', 'weganskie', 'wysokobialokowe'];
  List<String> selectedCharacteristics = ['wegetarianskie'];
  TextEditingController characteristicTec = TextEditingController();
  String characteristicPattern = '';




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

    characteristicTec.addListener((){
      setState(() {
        characteristicPattern = characteristicTec.text;
      });
    });
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Wyszukaj danie",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w500)),
          centerTitle: true,
        ),
        body: 
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  timeSelection(),
                  const SizedBox(height: 20),
                  ingredientsSelection(),
                  const SizedBox(height: 20),
                  chosenIngredients(selectedIngredients),
                  const SizedBox(height: 20),
                  CharacteristicsSelection(),
                  const SizedBox(height: 20),
                  chosenIngredients(selectedCharacteristics),
                  searchButton()
                ],
              ),
            ),

        );
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
              const Text(
                'Wybierz preferowany czas przygotowania potrawy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              DropdownButton<int>(
                  hint: const Text("Pick"),
                  value: _chosenTime,
                  items: cookingTimes.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
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
                  decoration: const InputDecoration(hintText: 'Wyszukaj składniki'),
                  controller: ingredientTec,),
              SizedBox(height: 120,child: displayFromList(ingredientPattern, allIngredients, selectedIngredients),)
            ],
          )),
    );
  }

  ListView displayFromList(String pattern, List<String> listIn, List<String> listOut) {
    List<String> displayedList = [];
    if (pattern.isNotEmpty) {
      for (int i = 0; i < listIn.length; i++) {
        if (listIn[i].contains(pattern)) {
          displayedList.add(listIn[i]);
        }
      }
    } else
      {displayedList = listIn;}
    return ListView.separated(
        padding: const EdgeInsets.all(8),
        separatorBuilder: (BuildContext context, int Index) => const SizedBox(width: 10,),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(

            onTap: (){setState(() {
              if(!listOut.contains(displayedList[index]))
              {
              listOut.add(displayedList[index]);
              }
            });},

            child: Container(
              decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black),
                            borderRadius: BorderRadius.circular(12)),
              height: 80,
              width: 160,
              child: Text(displayedList[index], textAlign: TextAlign.center,),
            ),
          );
        },
        itemCount: displayedList.length);
  }

  Padding chosenIngredients(List<String> selected)
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
              const Text('Wybrane'),
              SizedBox(height: 120,child: displayChosen(selected),)
            ],
          )),
    );
  }

  ListView displayChosen(List<String> selected)
  {
    return ListView.separated(
        padding: const EdgeInsets.all(8),
        separatorBuilder: (BuildContext context, int Index) => const SizedBox(width: 10,),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.black),
                          borderRadius: BorderRadius.circular(12)),
            height: 80,
            width: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(selectedIngredients[index], textAlign: TextAlign.center,),
                GestureDetector(onTap: () {
                  setState(() {
                    selected.remove(selected[index]);
                  });
                },
                child: Container
                (
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(width: 1), color: Colors.red[200]),
                  child: const Icon(Icons.remove)
                ),
                )
              ],
            ),
          );
        },
        itemCount: selectedIngredients.length);
  }

  Padding CharacteristicsSelection() {


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
                  decoration: const InputDecoration(hintText: 'Wyszukaj cechę'),
                  controller: characteristicTec,),
              SizedBox(height: 120,child: displayFromList(characteristicPattern, allCharacteristics, selectedCharacteristics),)
            ],
          )),
    );
  }

TextButton searchButton()
{
  return TextButton(onPressed: (){}, child: const Text('wyszukaj'));
}



}
