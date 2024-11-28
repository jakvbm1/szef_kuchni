
import 'package:flutter/material.dart';

class AppBarButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const AppBarButton(
    {
      super.key, 
      required this.onPressed, 
      required this.title,
    }
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed.call();
      }, 
      child: Text(
        title,
      )
    );
  }
}