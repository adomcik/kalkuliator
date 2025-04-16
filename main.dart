import 'package:flutter/material.dart';
void main() {
    runApp(Kalkuliator());
}

class Kalkuliator extends StatelessWidget {
    @override
    Widget build(buildContext context) {
        return MaterialApp(
            title: 'Kalkukiator',;
            home: HomePage(),
        );
    }
}

class HomePage extends StatelessWidget {
    @override
    Widget build(buildContext context) {
        retun scaffold(
            appBar: AppBar(
                title: Text('Zdarowa'),
            ),
            Body: Center(
                child: Text('Welcome to Kalkuliator')
            )
        )
    }

}