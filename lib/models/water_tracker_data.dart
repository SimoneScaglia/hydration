import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/water_intake_data.dart';

class WaterTrackerData {
  Future<Database> openDatabaseConnection() async {
    return openDatabase(
      join(await getDatabasesPath(), 'hydration_tracker.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE water_intake('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'date DATE NOT NULL, '
              'createDateTime TEXT NOT NULL'
              ');',
        );
      },
      version: 1,
    );
  }

  Future<List<Map<String, dynamic>>> getWaterIntakeByDate(Database db, DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return await db.query(
      'water_intake',
      where: 'date = ?',
      whereArgs: [formattedDate],
      orderBy: 'createDateTime ASC',
    );
  }

  Future<List<WaterIntakeData>> getEntriesForDate(Database db, DateTime date) async {
    final data = await getWaterIntakeByDate(db, date);
    return data.map((entry) {
      return WaterIntakeData(
        id: entry['id'],
        date: DateFormat('yyyy-MM-dd').parse(entry['date']),
        createDateTime: DateTime.parse(entry['createDateTime']),
      );
    }).toList();
  }

  Future<void> insertEntry(Database db, WaterIntakeData entry) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(entry.date);
    await db.insert('water_intake', {
      'date': formattedDate,
      'createDateTime': entry.createDateTime.toIso8601String(),
    });
  }

  Future<void> deleteEntry(Database db, int id) async {
    await db.delete(
      'water_intake',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
