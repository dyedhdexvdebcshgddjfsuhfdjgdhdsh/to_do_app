import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultButton({
  required double width,
  required Color color,
  required Function() function,
  required String text,
  double radius = 0.0,
}) =>
    Container(
      width: width,
      color: color,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
      child: MaterialButton(
        onPressed: function,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

Widget defaultTextFormField({
  required IconData prefixIcon,
  required TextEditingController controller,
  required TextInputType type,
  void Function(String)? onSubmitted,
  void Function(String)? onChanged,
  void Function()? onTap,
  String? Function(String?)? validate,
  IconData? suffixIcon,
  bool isPassword = false,
  Function? suffixPressed,
  required String label,
}) =>
    TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: type,
        onFieldSubmitted: onSubmitted,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon),
                  onPressed: suffixPressed!(),
                )
              : null,
        ),
        validator: validate);
Widget buildTaskItem(Map model, BuildContext context) {
  return Dismissible(
    background: Container(
      alignment: Alignment.center,
      color: Colors.redAccent,
      child: ListTile(
        leading: Icon(
          Icons.delete,
          color: Colors.white,
          size: 50,
        ),
        trailing: Icon(
          Icons.delete,
          color: Colors.white,
          size: 50,
        ),
      ),
    ),
    key: Key('$model[id]'.toString()),
    onDismissed: (direction) {
      AppCubit.get(context).deleteDatabase(id: model['id']);
    },
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            child: Text('${model['time']}'),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${model['title']}',
                  style: TextStyle(fontSize: 18.1, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '${model['date']}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          IconButton(
              onPressed: () {
                AppCubit.get(context)
                    .updateDatabase(status: 'done', id: model['id']);
              },
              color: Colors.green,
              icon: Icon(Icons.check_circle)),
          SizedBox(
            height: 20,
          ),
          IconButton(
              onPressed: () {
                AppCubit.get(context)
                    .updateDatabase(status: 'archived', id: model['id']);
              },
              color: Colors.black54,
              icon: Icon(Icons.archive_outlined))
        ],
      ),
    ),
  );
}

Widget buildemptyTasks({required List<Map> tasks}) {
  return ConditionalBuilder(
      condition: tasks.length > 0,
      builder: (context) {
        return ListView.separated(
            itemBuilder: (context, index) =>
                buildTaskItem(tasks[index], context),
            separatorBuilder: (context, index) {
              return Padding(
                padding: EdgeInsetsDirectional.only(start: 10),
                child: Container(
                  color: Colors.grey[300],
                  height: 1,
                  width: double.infinity,
                ),
              );
            },
            itemCount: tasks.length);
      },
      fallback: (context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty,
                color: Colors.grey,
                size: 100,
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                'No Tasks ,Please Add Some Tasks ...',
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        );
      });
}

// Widget myButton({
//   required String text,
//   void Function()? onPressed,
// }) {
//   return ElevatedButton(
//     onPressed: onPressed,
//     child: Text(text),
//   );
// }
