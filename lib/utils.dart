import 'package:sqflite/sqflite.dart';

class Utils{
  static late Database db;

  static String getFormattedDate(DateTime dateTime){
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}