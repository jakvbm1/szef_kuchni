import 'package:flutter/material.dart';
import 'package:szef_kuchni/Models/Recipe.dart';
import 'package:szef_kuchni/services/database_service.dart';

class RecipiesPage extends StatefulWidget {
  const RecipiesPage({super.key, required this.databaseService});

  final DatabaseService databaseService;

  @override
  State<RecipiesPage> createState() => _RecipiesPageState();
}

class _RecipiesPageState extends State<RecipiesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tasksList(),
    );
  }

  Widget _tasksList() {
    return FutureBuilder(
      future: widget.databaseService.getTasks(),
      builder: (context, snapshot) {
        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            Recipe recipe = snapshot.data![index];
            return ListTile(
              title: Text(
                recipe.name,
              ),
            );
          },
        );
      },
    );
  }
}