import 'dart:convert';
import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 0)
class Contact extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String company;

  Contact({
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
  });

  String toJsonString() {
    final map = {
      'name': name,
      'phone': phone,
      'email': email,
      'company': company,
    };
    return jsonEncode(map);
  }
}
