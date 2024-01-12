import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks.dart';
import 'package:todo_app/modules/done_tasks.dart';
import 'package:todo_app/modules/new_tasks.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitalState());

  // make object from AppCubit
  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    ArchivedTasksScreen(),
    DoneTasksScreen(),
  ];
  List<String> titles = ['Tasks', 'Archived', 'Done'];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppBottomNavBarState());
  }

  // create database
  Database? database;
  List<Map> new_tasks = [];
  List<Map> done_tasks = [];
  List<Map> archived_tasks = [];
  createDatabase() {
    openDatabase('todo.db', version: 2,
        onCreate: (Database database, int version) {
      database.execute('''
        CREATE TABLE tasks(
          "id" INTEGER PRIMARY KEY AUTOINCREMENT,
          "title" TEXT,
          "date" TEXT,
          "time" TEXT,
          "status" TEXT)
      ''').then((value) {
        print('Table created');
      }).catchError((error) {
        print('Error when creating database: ${error.toString()}');
      });
    }, onOpen: (Database database) {
      getDataFromDatabase(database);
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  void getDataFromDatabase(Database database) {
    emit(AppGetDatabaseLoadingState());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      // lists =zero when getdatabase again
      new_tasks = [];
      archived_tasks = [];
      done_tasks = [];
      value.forEach((element) {
        if (element['status'] == 'new') {
          new_tasks.add(element);
        } else if (element['status'] == 'done') {
          done_tasks.add(element);
        } else if (element['status'] == 'archived') {
          archived_tasks.add(element);
        }
        print(element['status']);
      });
      emit(AppGetDatabaseState());
    });
  }

  Future<List<Map>?>? rawInserTtoDatabase(
      {required String title, required String time, required String date}) {
    database!.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title,time,date,status)VALUES("${title}","${time}","${date}","new")')
          .then((value) {
        print('Insert Sucessfully');
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database!);
      }).catchError((error) {
        print('Error when Insert Record ${error.toString()}');
      });
    }).then((value) {});
    return null;
  }

  bool isBottomSheet = false;
  IconData fabIcon = Icons.edit;

  void isChangeBottomSheetState(
      {required IconData icon, required bool change}) {
    isBottomSheet = change;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }

  void updateDatabase({required String status, required int id}) {
    database?.rawUpdate('''
    UPDATE tasks 
    SET status=? 
    WHERE id =?
    ''', ['${status}', id]).then((value) {
      emit(AppUpdateDatabaseState());
      getDataFromDatabase(database!);
    });
  }

  void deleteDatabase({required int id}) {
    database?.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database!);
      emit(AppDeleteDatabaseState());
    });
  }
}
