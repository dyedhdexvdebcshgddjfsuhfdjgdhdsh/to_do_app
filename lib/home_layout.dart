import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/modules/reusable_components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';
import 'package:todo_app/sqldb.dart';

class HomeLayout extends StatefulWidget {
  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  // const HomeLayout({Key? key}) : super(key: key);
  sqlDB sqdb = sqlDB();

  var scaffoldKey = GlobalKey<ScaffoldState>();

  var formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();

  TextEditingController timeController = TextEditingController();

  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          if (state is AppInsertDatabaseState) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            // key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
              centerTitle: true,
            ),
            drawer: Drawer(),
            floatingActionButton: FloatingActionButton(
                child: Icon(cubit.fabIcon),
                onPressed: () {
                  //    int response = await sqdb.rawInsertData("INSERT INTO tasks(title,date,time,status)VALUES('ahmed','23/11/2023','04:23','succed')");
                  //   print(response);
                  if (cubit.isBottomSheet == true) {
                    if (formKey.currentState!.validate()) {
                      cubit
                          .rawInserTtoDatabase(
                              title: titleController.text,
                              time: timeController.text,
                              date: dateController.text)
                          ?.then((value) {
                        cubit.isChangeBottomSheetState(
                            icon: Icons.edit, change: false);
                      });
                    }
                  } else {
                    scaffoldKey.currentState!
                        .showBottomSheet((context) {
                          return Container(
                            padding: EdgeInsets.all(20.0),
                            color: Colors.white,
                            child: Form(
                              key: formKey,
                              child: Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      defaultTextFormField(
                                          validate: (String? value) {
                                            if (value!.isEmpty) {
                                              return 'Field must not be Empty';
                                            }
                                            return null;
                                          },
                                          prefixIcon: Icons.title,
                                          controller: titleController,
                                          type: TextInputType.text,
                                          label: 'Task Title'),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      defaultTextFormField(
                                          validate: (String? value) {
                                            if (value!.isEmpty) {
                                              return 'Time must not be Empty';
                                            }
                                            return null;
                                          },
                                          prefixIcon:
                                              Icons.watch_later_outlined,
                                          controller: timeController,
                                          type: TextInputType.datetime,
                                          label: 'Task Time',
                                          onTap: () {
                                            // print('time tapped');
                                            showLoading();
                                            showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now())
                                                .then((value) {
                                              timeController.text =
                                                  value!.format(context);
                                              print(value.format(context));
                                            });
                                          }),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      defaultTextFormField(
                                          validate: (String? value) {
                                            if (value!.isEmpty) {
                                              return 'Date must not be Empty';
                                            }
                                            return null;
                                          },
                                          prefixIcon: Icons.date_range_outlined,
                                          controller: dateController,
                                          type: TextInputType.datetime,
                                          label: 'Task Date',
                                          onTap: () {
                                            // print('Date tapped');
                                            showLoading();
                                            showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime.parse(
                                                        "2023-11-30"))
                                                .then((value) {
                                              dateController.text =
                                                  DateFormat.yMMMd()
                                                      .format(value!);
                                            });
                                            // print(value!.format(DateFormat.yMMMd().format(value!)));
                                          })
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }, elevation: 100.0)
                        .closed
                        .then((value) {
                          cubit.isChangeBottomSheetState(
                              icon: Icons.edit, change: false);
                        });
                    cubit.isChangeBottomSheetState(
                        icon: Icons.add, change: true);
                  }
                }),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: 'Archived'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline), label: 'Done'),
              ],
            ),
            body: ConditionalBuilder(
                condition: state is! AppGetDatabaseLoadingState,
                builder: (context) => cubit.screens[cubit.currentIndex],
                fallback: (context) => Center(
                      child: CircularProgressIndicator(),
                    )),
          );
        },
      ),
    );
  }

  Widget showLoading() {
    Future.delayed(Duration(microseconds: 100));
    return Center(child: CircularProgressIndicator());
  }

  Future InsertData(
      {required String title,
      required String time,
      required String date}) async {
    return await sqdb.rawInsertData(
        'INSERT INTO tasks(title,time,date,status)VALUES("${title}","${time}","${date}","new")');
  }
}
