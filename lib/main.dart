import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/home_layout.dart';
import 'package:todo_app/shared/bloc_observer.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  ThemeMode _themeMode = ThemeMode.system;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: themeNotifier,
        builder: (context, currentMode, child) {
          return MaterialApp(
            theme: ThemeData(primarySwatch: Colors.amber),
            darkTheme: ThemeData.dark(),
            themeMode: currentMode,
            debugShowCheckedModeBanner: false,
            home: HomeLayout(),
          );
        });
  }
}
