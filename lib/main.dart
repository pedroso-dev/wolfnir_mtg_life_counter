import 'package:flutter/material.dart';

void main() {
  runApp(const MTGCounterApp());
}

class MTGCounterApp extends StatelessWidget {
  const MTGCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MTG Life Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(child: Text('MTG Commander Counter v0.1.0')),
      ),
    );
  }
}
