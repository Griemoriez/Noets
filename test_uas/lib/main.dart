import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_uas/homepage.dart';
import 'package:test_uas/login.dart';
import 'package:test_uas/models/note.dart';
import 'package:test_uas/models/pin.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(PinAdapter());

  await Hive.openBox<Note>('notes');
  var pinBox = await Hive.openBox<Pin>('pinBox');
  print(pinBox.get('userPin')?.pin);
  
  if (pinBox.get('userPin') == null) {
    pinBox.put('userPin', Pin('1234'));
  }
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            textTheme:
                const TextTheme(bodyMedium: TextStyle(fontFamily: 'Inter'))),
        debugShowCheckedModeBanner: false,
        home: Login());
  }
}
