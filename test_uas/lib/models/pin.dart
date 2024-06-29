import 'package:hive/hive.dart';

part 'pin.g.dart';

@HiveType(typeId: 1)
class Pin {
  @HiveField(0)
  String pin;

  Pin(this.pin);
}
