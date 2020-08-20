import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_todo_demo/common/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo Demo',
      theme: appTheme,
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  TextEditingController _controller;
  final CollectionReference collection =
      FirebaseFirestore.instance.collection("Todos");

  List todos = List();
  String input;
  BuildContext _scaffoldContext;

  void showErrorMessage(String msg) {
    final snackBar = SnackBar(
            content: Text(msg),
            action: SnackBarAction(
              label: 'Close',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );

          // Find the Scaffold in the widget tree and use
          // it to show a SnackBar.
          Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  void createTodos() {
    Map<String, String> todos = {"todoTitle": input};
    collection.add(todos).whenComplete(() => showErrorMessage('Todo added successfully'));
  }

  void deleteTodos(DocumentSnapshot doc) {
    collection.doc(doc.id).delete().whenComplete(() => showErrorMessage('Todo deleted successfully'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Todos")),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {                
                  return AlertDialog(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    title: Text("Add Todolist"),
                    content: TextField(
                      controller: _controller,
                      onChanged: (String value) {
                        input = value;
                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                          textColor: Colors.black,
                          onPressed: () {
                            createTodos();
                            Navigator.of(context).pop();
                          },
                          child: Text('Add'))
                    ],
                  );
                });
          },
          child: Icon(Icons.add),
        ),
        body: StreamBuilder(
            stream: collection.snapshots(),
            builder: (context, snapshot) {
               _scaffoldContext = context;
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );
              if (snapshot.data.documents.length == 0)
                return Center(
                    child: Text(
                  "No data available",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ));
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot =
                        snapshot.data.documents[index];
                    return Dismissible(
                        onDismissed: (direction) {
                          deleteTodos(documentSnapshot);
                        },
                        background: Container(color: Colors.red),
                        key: Key(index.toString()),
                        child: Card(
                            elevation: 4,
                            margin: EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              title: Text(documentSnapshot.get('todoTitle')),
                              trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    deleteTodos(documentSnapshot);
                                  }),
                            )));
                  });
            }));
  }
}
