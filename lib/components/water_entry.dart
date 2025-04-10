import 'package:flutter/material.dart';
import 'package:hydration/models/water_intake_data.dart';
import 'package:intl/intl.dart';

class WaterEntry extends StatelessWidget {
  final WaterIntakeData waterData;
  final Function onDelete;

  const WaterEntry({
    required this.waterData,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String timeFormatted = DateFormat.Hms().format(waterData.createDateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade100,
          border: Border.all(color: Colors.blueGrey),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: ListTile(
          leading: const Icon(Icons.local_drink_outlined, color: Colors.blue),
          title: const Text('Bicchiere d’acqua'),
          subtitle: Text('Orario: $timeFormatted'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => onDelete(),
          ),
        ),
      ),
    );
  }
}
