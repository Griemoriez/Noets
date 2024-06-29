import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_uas/login.dart';
import 'package:test_uas/models/note.dart';
import 'package:test_uas/noteCard.dart';
import 'package:test_uas/models/pin.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Box<Note> _noteBox;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final _form = GlobalKey<FormState>();

  final _formChangePIN = GlobalKey<FormState>();
  final current_PIN_Controller = TextEditingController();
  final new_PIN_Controller = TextEditingController();
  final confirm_PIN_Controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _noteBox = Hive.box<Note>('notes');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/bg_home.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
                onPressed: () {
                  _showChangePin(context);
                },
                icon: Icon(Icons.settings)),
          ),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, Justin",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Bring Changes with Noets",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    Icon(
                      Icons.person,
                      size: 70,
                    )
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                SizedBox(
                  height: 500,
                  child: ValueListenableBuilder(
                    valueListenable: _noteBox.listenable(),
                    builder: (context, Box<Note> notes, _) {
                      if (notes.values.isEmpty) {
                        return Center(
                            child: Text(
                          'No notes yet',
                          style: TextStyle(),
                        ));
                      }
                      return ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          Note note = notes.getAt(index)!;
                          return GestureDetector(
                            child: NoteCard(
                              index: index,
                              title: note.title,
                              lastEdited: note.lastEditedDate,
                              createdDate: note.createdDate,
                            ),
                            onTap: () {
                              _showEditNote(context, index);
                            },
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
              backgroundColor: Color(0xffF9EA85),
              child: Icon(
                Icons.add,
                weight: 10,
              ),
              onPressed: () {
                _showAddNote(context);
              }),
        ),
      ],
    );
  }

  Future<void> _showChangePin(BuildContext context) async {
    String errorMessage = '';
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Change PIN'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            content: Container(
                width: 300,
                height: 500,
                child: Form(
                    key: _formChangePIN,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: current_PIN_Controller,
                          decoration: InputDecoration(labelText: 'Current PIN'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your current PIN';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: new_PIN_Controller,
                          decoration: InputDecoration(labelText: 'New PIN'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new PIN';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: confirm_PIN_Controller,
                          decoration:
                              InputDecoration(labelText: 'Confirm New PIN'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your new PIN';
                            }
                            return null;
                          },
                        ),
                        if (errorMessage != '')
                          Container(
                            margin: EdgeInsets.only(top: 8.0),
                            padding: EdgeInsets.all(8.0),
                            color: Colors.red.withOpacity(0.1),
                            child: Text(
                              errorMessage,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ))),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Color(0xffF9EA85)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Change PIN',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                onPressed: () async {
                  if (_formChangePIN.currentState!.validate()) {
                    print("form masuk");
                    var pinBox = await Hive.openBox<Pin>('pinBox');
                    if (current_PIN_Controller.text ==
                        pinBox.get('userPin')?.pin) {
                      print("current pin masuk");
                      if (new_PIN_Controller.text ==
                          confirm_PIN_Controller.text) {
                        pinBox.put('userPin', Pin(new_PIN_Controller.text));
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      } else {
                        _showErrorNote(context, "Confirm PIN doesn't match");
                        current_PIN_Controller.clear();
                        confirm_PIN_Controller.clear();
                        new_PIN_Controller.clear();
                      }
                    } else {
                      _showErrorNote(context, "Current PIN doesn't match");
                      current_PIN_Controller.clear();
                      confirm_PIN_Controller.clear();
                      new_PIN_Controller.clear();
                    }
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> _showErrorNote(BuildContext context, String msg) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Noets Warning'),
          backgroundColor: Color(0xffF9EA85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: Container(
              width: 350,
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    msg,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Icon(
                    Icons.error,
                    color: Colors.red[900],
                    size: 100,
                  )
                ],
              )),
        );
      },
    );
  }

  Future<void> _showAddNote(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Note'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: Container(
              width: 300,
              height: 500,
              child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ))),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Color(0xffF9EA85)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              onPressed: () async {
                if (_form.currentState!.validate()) {
                  var box = await Hive.openBox<Note>('notes');
                  var newNote = Note(
                      title: titleController.text,
                      content: descriptionController.text,
                      createdDate: DateTime.now(),
                      lastEditedDate: DateTime.now());
                  box.add(newNote);
                  titleController.clear();
                  descriptionController.clear();
                  Navigator.pop(context);
                }
              },
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.red.shade400),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditNote(BuildContext context, int index) async {
    var box = await Hive.openBox<Note>('notes');
    titleController.text = box.getAt(index)!.title;
    descriptionController.text = box.getAt(index)!.content;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Note'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: Container(
              width: 300,
              height: 500,
              child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ))),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.green[400]),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Edit',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              onPressed: () async {
                if (_form.currentState!.validate()) {
                  var box = await Hive.openBox<Note>('notes');
                  var tempNote = box.getAt(index);
                  var newNote = Note(
                      title: titleController.text,
                      content: descriptionController.text,
                      createdDate: tempNote!.createdDate,
                      lastEditedDate: DateTime.now());
                  box.putAt(index, newNote);
                  Navigator.pop(context);
                }
              },
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Color(0xffF9EA85)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.red[400]),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              onPressed: () async {
                var box = await Hive.openBox<Note>('notes');
                box.deleteAt(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
