import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExerciseGraph extends StatefulWidget {
  @override
  _ExerciseGraphState createState() => _ExerciseGraphState();
}

class _ExerciseGraphState extends State<ExerciseGraph> {
  Map<String, int> counterSumByExercise = {};
  Map<String, int> timeSumByExercise = {};

  @override
  void initState() {
    super.initState();
    _fetchExerciseData(); // 모든 운동 기록 가져오기
  }

  // Firestore에서 운동 기록 가져오기
  Future<void> _fetchExerciseData() async {
    final user = FirebaseAuth.instance.currentUser;
    final year = DateTime.now().year.toString();
    final month = DateTime.now().month.toString().padLeft(2, '0');
    final today = '${year}-${month}';

    if (user != null) {
      final uid = user.uid;

      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('exercise_days')
            .orderBy('exerciseDate')
            .startAt([today])
            .get();

        final Map<String, List<Map<String, dynamic>>> exerciseData = {};

        // Firestore로부터 가져온 데이터 날짜별로 정리
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          final docDate = data['exerciseDate']; // 예: "2024-12-10"

          if (docDate != null && docDate is String && docDate.isNotEmpty) {
            exerciseData.putIfAbsent(docDate, () => []);
            exerciseData[docDate]!.add({
              "exerciseName": data['exerciseName'] ?? "",
              "totalCounter": data['totalCounter'] ?? 0,
              "exerciseTime": data['exerciseTime'] ?? 0,
            });
          }
        }

        // 여기까지는 기존 형식을 그대로 유지

        // 여기서부터 지난 7일간의 데이터만 추려서, 운동종목별로 총합을 낸다.
        final now = DateTime.now();
        final sevenDaysAgo = now.subtract(const Duration(days: 7));

        // 지난 7일간 해당하는 데이터만 추출
        final Map<String, int> counterSumByExercise = {};
        final Map<String, int> timeSumByExercise = {};

        exerciseData.forEach((dateString, exercises) {
          // dateString -> "2024-12-10" 형태를 DateTime으로 파싱
          final parts = dateString.split('-');
          if (parts.length == 3) {
            final year = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final day = int.tryParse(parts[2]);
            if (year != null && month != null && day != null) {
              final date = DateTime(year, month, day);
              // 지난 7일 범위 안에 해당하는 날짜인지 확인
              if (date.isAfter(sevenDaysAgo) && !date.isAfter(now)) {
                for (var ex in exercises) {
                  final name = ex["exerciseName"] ?? "";
                  final counter =
                      int.tryParse(ex["totalCounter"].toString()) ?? 0;
                  final time = int.tryParse(ex["exerciseTime"].toString()) ?? 0;

                  counterSumByExercise[name] =
                      (counterSumByExercise[name] ?? 0) + counter;
                  timeSumByExercise[name] =
                      (timeSumByExercise[name] ?? 0) + time;
                }
              }
            }
          }
        });

        // setState로 데이터 업데이트
        setState(() {
          this.counterSumByExercise = counterSumByExercise;
          this.timeSumByExercise = timeSumByExercise;
        });

        // 결과 출력 (형식 그대로 두고, 추가적인 출력만)
        print('All Exercise Data Loaded: $exerciseData');
        print('=== 지난 7일간 운동합계 ===');
        counterSumByExercise.forEach((name, totalCounter) {
          final totalTime = timeSumByExercise[name] ?? 0;
          print('$name: totalCounter=$totalCounter, totalTime=$totalTime');
        });
      } catch (e) {
        print('Error fetching exercise data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("운동 기록 그래프"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: counterSumByExercise.isNotEmpty
            ? SingleChildScrollView( // 스크롤 가능하도록 감싸기
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "운동 기록 (지난 7일)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity, // 부모로부터 가로 크기 받음
                height: 300, // Y축 크기 제한
                child: BarChart(
                  BarChartData(
                    barGroups: _generateBarGroups(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final keys =
                            counterSumByExercise.keys.toList();
                            if (value.toInt() < keys.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(keys[value.toInt()]),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
            ],
          ),
        )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }


  List<BarChartGroupData> _generateBarGroups() {
    final keys = counterSumByExercise.keys.toList();
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < keys.length; i++) {
      final name = keys[i];
      final count = counterSumByExercise[name] ?? 0;
      final time = timeSumByExercise[name] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: count.toDouble(), color: Colors.blue),
            BarChartRodData(toY: time.toDouble(), color: Colors.red),
          ],
          showingTooltipIndicators: [0, 1],
        ),
      );
    }

    return barGroups;
  }
}