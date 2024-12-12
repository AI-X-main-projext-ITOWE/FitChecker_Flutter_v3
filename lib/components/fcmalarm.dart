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
      // 데이터를 Map으로 변환
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _alarms = data.entries.map((entry) {
          return {
            'id': entry.key, // 고유 ID
            'alarm_text': entry.value['alarm_text'],
            'alarm_time': entry.value['alarm_time'],
          };
        }).toList();

        // 최신 날짜 순으로 정렬 (내림차순 정렬)
        _alarms.sort((a, b) => b['alarm_time'].compareTo(a['alarm_time']));
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
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _alarms.length,
        itemBuilder: (context, index) {
          final alarm = _alarms[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: ListTile(
              leading: Icon(Icons.notifications, color: Colors.blue),
              title: Text(
                alarm['alarm_text'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Time: ${alarm['alarm_time']}',
                style: TextStyle(color: Colors.grey),
              ),
              contentPadding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              onTap: () {
                // 알림 클릭 시 추가 기능 (예: 알림 상세보기)
              },
            ),
          );
        },
      ),
    );
  }
}