import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seniorshield/constants/colors.dart';
import 'package:seniorshield/widgets/responsive_text.dart';

class RecordsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Health Records',
          textColor: kDefaultIconLightColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: kDefaultIconLightColor,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: APIs.getSensorDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          List<DataRow> rows = snapshot.data!.entries.map<DataRow>((entry) {
            return DataRow(cells: [
              DataCell(Text('${snapshot.data!.keys.toList().indexOf(entry.key) + 1}', style: TextStyle(fontSize: 16))),
              DataCell(Text(entry.key, style: TextStyle(fontSize: 16))), // Time
              DataCell(Text(entry.value['BPM'].toString() ?? 'N/A', style: TextStyle(fontSize: 16))),
              DataCell(Text(entry.value['SpO2'].toString() ?? 'N/A', style: TextStyle(fontSize: 16))),
              DataCell(Text(entry.value['piezoValue'].toString() ?? 'N/A', style: TextStyle(fontSize: 16))),
            ]);
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 38.0,
                horizontalMargin: 20.0,
                dataTextStyle: TextStyle(fontSize: 14, color: Colors.black),
                headingTextStyle: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                columns: const [
                  DataColumn(label: Text('S.N')),
                  DataColumn(label: Text('Time')),
                  DataColumn(label: Text('BPM')),
                  DataColumn(label: Text('SpO2')),
                  DataColumn(label: Text('Piezo')),
                ],
                rows: rows,
              ),
            ),
          );
        },
      ),
    );
  }
}


class APIs {
  static final databaseRef = FirebaseDatabase.instance.ref();

  static Stream<Map<String, dynamic>> getSensorDataStream() {
    return databaseRef.child('sensorData').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      Map<String, dynamic> formattedData = {};

      // Create a sorted list of entries by timestamp in descending order
      var sortedEntries = data.entries.toList();
      sortedEntries.sort((a, b) => (b.value['fields']['timestamp'] as int).compareTo(a.value['fields']['timestamp'] as int));

      for (var entry in sortedEntries) {
        var timestamp = entry.value['fields']['timestamp'] as int;
        var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        var formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
        formattedData[formattedTime] = entry.value['fields'];
      }

      return formattedData;
    });
  }
}
