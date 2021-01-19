import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Task List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  bool tasksLoaded = false;
  var tasks = [];

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Task {
  final String name;

  const Task({
    this.name
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'].toString()
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasksLoaded == false)
    {
      var url = "https://tjqibz5dpg.execute-api.us-east-2.amazonaws.com/dev/tasks";
      http.get(url).then((http.Response response) {
        setState(() {
          final int statusCode = response.statusCode;
          if (statusCode == 200) {
            final temp = json.decode(response.body);
            for (var item in temp) {
              Task temp_task = Task.fromJson(item);
              widget.tasks.add(temp_task);
            }
          }
          widget.tasksLoaded = true;
        });
      });
    }

    var tasksText = <Padding>[];
    widget.tasks.forEach( (str) {
      var textField = new Padding(padding: EdgeInsets.only(top: 10.0, left: 10.0),
          child: new Text(str.name));
      tasksText.add(textField);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: tasksText
        ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskView()),
          );
        },
        child: Text('Create task'),
      ),
    );
  }
}

class CreateTaskView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final taskNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create task"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(top: 10.0, left: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Task name"),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Name of the task is empty';
                  }
                  return null;
                },
                controller: taskNameController
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    var url = "https://tjqibz5dpg.execute-api.us-east-2.amazonaws.com/dev/tasks";
                    return http
                        .post(url,
                        body: "{" +
                            "\"name\": \"${taskNameController.text}\" }")
                        .then((http.Response response) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyApp(),
                            ),
                      );
                    });
                  }
                },
                child: Text('Create task'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back'),
              )
            ],
        ),),
      ),
    );
  }
}