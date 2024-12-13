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
      // 데이터 로딩 중일 때 로딩 인디케이터 표시
      return Center(child: CircularProgressIndicator());
    }

    // 화면 너비를 가져와 그래프 크기 설정
    double screenWidth = MediaQuery.of(context).size.width;
    double chartSize = screenWidth * 0.9; // 화면 너비의 90%

    // Y축의 최댓값과 최솟값 계산
    int maxCounter = counterSumByExercise.values.isNotEmpty
        ? counterSumByExercise.values.reduce((a, b) => a > b ? a : b)
        : 0;
    double adjustedMaxY = (maxCounter * 1.2).ceilToDouble();

    // List of exercise names and their counts
    final exerciseNames = counterSumByExercise.keys.toList();
    final exerciseCounts = counterSumByExercise.values.toList();

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "● 운동 기록 (지난 7일)",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 8),
          // Stack to overlay dots on top of the bar chart
          Stack(
            alignment: Alignment.center,
            children: [
              // 그래프에 border-radius를 추가하고, 위와 아래 글자가 잘리지 않도록 패딩을 추가
              ClipRRect(
                borderRadius: BorderRadius.circular(16), // border-radius 추가
                clipBehavior: Clip.antiAlias, // 클리핑 설정
                child: Container(
                  padding: EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20), // 패딩 조정
                  width: chartSize,
                  height: chartSize, // 컨테이너 높이 추가 증가
                  color: Colors.grey[900], // 어두운 배경색 설정
                  child: BarChart(
                    BarChartData(
                      backgroundColor: Colors.transparent, // Container의 배경색 사용
                      minY: 0,
                      maxY: adjustedMaxY,
                      barGroups: _generateBarGroups(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                            interval: adjustedMaxY / 5,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
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
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // 위 숫자 제거
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // 오른쪽 숫자 제거
                        ),
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
                      // 툴팁 설정
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 8, // 툴팁의 둥근 모서리
                          tooltipPadding: EdgeInsets.all(8), // 툴팁 내부 패딩
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
