import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLoC Pattern Example',
      home: BlocProvider(
        create: (context) => ColorBloc(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorBloc colorBloc = BlocProvider.of<ColorBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('BLoC Pattern Example'),
      ),
      body: Center(
        child: BlocBuilder<ColorBloc, List<Color>>(
          builder: (context, colorList) => ListView.builder(
            itemCount: colorList.length,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                height: 200,
                color: colorList[index],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          colorBloc.add(ColorEvent.addContainer);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

enum ColorEvent { addContainer }

class ColorBloc extends Bloc<ColorEvent, List<Color>> {
  ColorBloc() : super([Colors.grey]);

  @override
  Stream<List<Color>> mapEventToState(ColorEvent event) async* {
    if (event == ColorEvent.addContainer) {
      yield [...state, getRandomColor()];
    }
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}
