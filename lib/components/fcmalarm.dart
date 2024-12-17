import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AlarmListPage extends StatefulWidget {
  @override
  _AlarmListPageState createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage> {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref(); // Firebase Database 참조
  List<Map<String, dynamic>> _alarms = []; // 알림 데이터를 저장할 리스트

  @override
  void initState() {
    super.initState();
    _fetchAlarms();
  }

  // Firebase에서 alarms 데이터를 가져오는 함수
  void _fetchAlarms() async {
    final snapshot = await _databaseReference.child('alarms').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> loadedAlarms = [];

      // 중첩된 하위 노드를 순회하며 알림 데이터를 수집
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          value.forEach((subKey, alarmData) {
            if (alarmData is Map<dynamic, dynamic>) {
              loadedAlarms.add({
                'id': subKey,
                'alarm_text': alarmData['alarm_text'] ?? 'No text',
                'response': alarmData['response'] ?? 'No response',
                'alarm_time': alarmData['alarm_time'] ?? '',
              });
            }
          });
        }
      });

      // 최신 날짜 순으로 정렬
      loadedAlarms.sort((a, b) {
        final timeA = a['alarm_time'];
        final timeB = b['alarm_time'];

        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        return timeB.compareTo(timeA);
      });

      setState(() {
        _alarms = loadedAlarms;
      });
    } else {
      print("No data found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Alarms')),
      body: _alarms.isEmpty
          ? FutureBuilder(
        future: _databaseReference.child('alarms').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else
          if (!snapshot.hasData || snapshot.data == null || _alarms.isEmpty) {
            return Center(
              child: Text(
                '저장된 알람이 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: Colors.blue),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alarm['alarm_text'], // 기존 알람 내용
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          alarm['response'], // 추가된 response 내용
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Time: ${alarm['alarm_time']}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    contentPadding: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
            );
          }
        },
      )
          : ListView.builder(
        itemCount: _alarms.length,
        itemBuilder: (context, index) {
          final alarm = _alarms[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: ListTile(
              leading: Icon(Icons.notifications, color: Colors.blue),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarm['alarm_text'], // 기존 알람 내용
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    alarm['response'], // 추가된 response 내용
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              subtitle: Text(
                'Time: ${alarm['alarm_time']}',
                style: TextStyle(color: Colors.grey),
              ),
              contentPadding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }
}
