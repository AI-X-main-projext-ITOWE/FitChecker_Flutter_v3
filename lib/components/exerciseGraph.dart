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
  bool isLoading = true; // 로딩 상태 변수 선언

  @override
  void initState() {
    super.initState();
    _fetchExerciseData(); // 모든 운동 기록 가져오기
  }

  // Firestore에서 운동 기록 가져오기
  Future<void> _fetchExerciseData() async {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 6));

    if (user != null) {
      final uid = user.uid;

      try {
        // Firestore 쿼리 수정: 'exerciseDate' 필드가 'yyyy-MM-dd' 형식이라고 가정
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('exercise_days')
            .where('exerciseDate', isGreaterThanOrEqualTo: _formatDate(sevenDaysAgo))
            .where('exerciseDate', isLessThanOrEqualTo: _formatDate(now))
            .orderBy('exerciseDate', descending: false)
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

        // 지난 7일간의 데이터만 추려서, 운동종목별로 총합을 계산
        final Map<String, int> tempCounterSum = {};
        final Map<String, int> tempTimeSum = {};

        exerciseData.forEach((dateString, exercises) {
          for (var ex in exercises) {
            final name = ex["exerciseName"] ?? "";
            final counter = int.tryParse(ex["totalCounter"].toString()) ?? 0;
            final time = int.tryParse(ex["exerciseTime"].toString()) ?? 0;

            tempCounterSum[name] = (tempCounterSum[name] ?? 0) + counter;
            tempTimeSum[name] = (tempTimeSum[name] ?? 0) + time;
          }
        });

        // setState로 데이터 업데이트 및 로딩 완료
        setState(() {
          counterSumByExercise = tempCounterSum;
          timeSumByExercise = tempTimeSum;
          isLoading = false; // 로딩 완료
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
        setState(() {
          isLoading = false; // 에러 발생 시 로딩 종료
        });
      }
    } else {
      setState(() {
        isLoading = false; // 유저가 없을 경우 로딩 종료
      });
    }
  }

  // 날짜를 'yyyy-MM-dd' 형식으로 포맷팅하는 헬퍼 함수
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double chartSize = screenWidth * 0.9;

    int maxCounter = counterSumByExercise.values.isNotEmpty
        ? counterSumByExercise.values.reduce((a, b) => a > b ? a : b)
        : 0;
    double adjustedMaxY = (maxCounter * 1.2).ceilToDouble();

    final exerciseNames = counterSumByExercise.keys.toList();

    // 일주일간 총 운동 시간
    int totalTime = timeSumByExercise.values.fold(0, (sum, time) => sum + time);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // 여기 수정
        children: [
          Text(
            "● 운동 기록 (지난 7일)",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 8),
          // 기존 그래프를 중앙 정렬
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    padding: EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
                    width: chartSize,
                    height: chartSize,
                    color: Colors.grey[900],
                    child: BarChart(
                      BarChartData(
                        backgroundColor: Colors.transparent,
                        minY: 0,
                        maxY: adjustedMaxY,
                        barGroups: _generateBarGroups(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < exerciseNames.length) {
                                  String exercise = exerciseNames[value.toInt()];
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      exercise,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          horizontalInterval: adjustedMaxY / 5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white12,
                              strokeWidth: 1,
                            );
                          },
                          drawVerticalLine: false,
                        ),
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            tooltipPadding: EdgeInsets.all(8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String exercise = counterSumByExercise.keys.toList()[group.x.toInt()];
                              return BarTooltipItem(
                                '$exercise\n',
                                TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${rod.toY.toInt()} 회',
                                    style: TextStyle(
                                      color: Colors.yellowAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // 추가된 부분
          ExerciseSummary(
            totalTime: totalTime,
            exerciseCounts: counterSumByExercise,
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }


  List<BarChartGroupData> _generateBarGroups() {
    final keys = counterSumByExercise.keys.toList();
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < keys.length; i++) {
      final name = keys[i];
      final count = counterSumByExercise[name] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.blueAccent,
              width: 20, // 막대 너비 조정
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)), // 막대 모서리 둥글게
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return barGroups;
  }
}

class ExerciseSummary extends StatelessWidget {
  final int totalTime; // 총 운동 시간
  final Map<String, int> exerciseCounts; // 운동별 총 횟수
  final Map<String, double> caloriesPerMinute = {
    'push-up': 3.5,
    'pull-up': 4.0,
    'squat': 5.0,
    'sit-up': 3.0,
  };

  ExerciseSummary({required this.totalTime, required this.exerciseCounts});

  double _calculateTotalCalories() {
    double totalCalories = 0;
    exerciseCounts.forEach((exerciseName, count) {
      double calories = caloriesPerMinute[exerciseName] ?? 0;
      totalCalories += (calories * count / 60); // 칼로리 계산
    });
    return totalCalories;
  }

  @override
  Widget build(BuildContext context) {
    double totalCalories = _calculateTotalCalories();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 총 운동 시간 컨테이너
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.width * 0.4,
          decoration: BoxDecoration(
            color: Color(0xFF212121),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "총 운동 시간",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "${(totalTime ~/ 60)}분 ${totalTime % 60}초",
                  style: TextStyle(
                    color: Colors.yellowAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 소모 칼로리 컨테이너
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.width * 0.4,
          decoration: BoxDecoration(
            color: Color(0xFF212121),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "소모 칼로리",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "${totalCalories.toStringAsFixed(1)} kcal",
                  style: TextStyle(
                    color: Colors.yellowAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}