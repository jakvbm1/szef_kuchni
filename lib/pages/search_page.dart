import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchPage extends StatefulWidget {
    @override
  State<StatefulWidget> createState() {
    return SearchState();
  }


}

class SearchState extends State<SearchPage>
{
  List<int> cookingTimes = [];
  int? _chosenTime;
  @override
  void initState() {
    for(int i=0; i<20; i++)
    {
      cookingTimes.add((i+1) * 5);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      appBar: AppBar(title: Text("Wyszukaj danie", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w500)), centerTitle: true,),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          timeSelection(),
        ],
      )
    );
  }

  Padding timeSelection()
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container
      (
        height: 100,
        decoration: BoxDecoration(border: Border.all(width: 8, color: Colors.black), borderRadius: BorderRadius.circular(16)),
        child:Row
        (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: 
          [
            Text('Wybierz preferowany czas przygotowania potrawy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),),
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
        )
      ),
    );
  } 
  
}
