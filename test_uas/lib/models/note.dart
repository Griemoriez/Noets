import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime createdDate;

  @HiveField(3)
  DateTime lastEditedDate;

  Note({
    required this.title,
    required this.content,
    required this.createdDate,
    required this.lastEditedDate,
  });
}
