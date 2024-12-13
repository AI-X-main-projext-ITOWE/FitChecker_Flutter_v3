import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitchecker/models/user_model.dart';
import 'package:fitchecker/services/auth_service.dart';
import 'home_screen.dart';

class UserInfoScreen extends StatefulWidget {
  final User user;

  const UserInfoScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  bool isMaleSelected = false;
  bool isFemaleSelected = false;

  void _toggleGender(bool isMale) {
    setState(() {
      isMaleSelected = isMale;
      isFemaleSelected = !isMale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200], // 배경색 변경
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 원하는 배경색 설정
            borderRadius: BorderRadius.circular(12), // 선택적으로 둥근 테두리 추가
            boxShadow: [ // 선택적으로 그림자 추가
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0), // 내부 패딩
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '● 성별을 선택해주세요.',
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isMaleSelected,
                      onChanged: (bool? value) {
                        if (value != null) _toggleGender(true);
                      },
                    ),
                    const Text('남성'),
                    Checkbox(
                      value: isFemaleSelected,
                      onChanged: (bool? value) {
                        if (value != null) _toggleGender(false);
                      },
                    ),
                    const Text('여성'),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('● 현재 나이를 입력해주세요.', style: TextStyle(fontSize: 18)),
                Container(
                  width: screenWidth * 0.9, // 입력창 가로 길이 제한
                  child: TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('● 키를 입력해주세요.', style: TextStyle(fontSize: 18)),
                Container(
                  width: screenWidth * 0.9, // 입력창 가로 길이 제한
                  child: TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "(cm)",
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('● 몸무게를 입력해주세요.', style: TextStyle(fontSize: 18)),
                Container(
                  width: screenWidth * 0.9, // 입력창 가로 길이 제한
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "(kg)",
                        border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(height: 20), // 입력 필드와 버튼 간의 간격
                Divider(),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (ageController.text.isNotEmpty &&
                            heightController.text.isNotEmpty &&
                            weightController.text.isNotEmpty &&
                            (isMaleSelected || isFemaleSelected)) {
                          final age = ageController.text;
                          final height = heightController.text;
                          final weight = weightController.text;
                          final gender = isMaleSelected ? 'male' : 'female';

                          final userModel = UserModel(
                            id: widget.user.uid,
                            email: widget.user.email ?? '',
                            name: widget.user.displayName ?? '',
                            age: age,
                            height: height,
                            weight: weight,
                            gender: gender,
                            photoUrl: widget.user.photoURL,
                          );

                          // Firestore에 저장
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.user.uid)
                              .set(userModel.toMap());

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('모든 정보를 입력해주세요.')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('오류 발생: $e')),
                        );
                      }
                    },
                    child: const Text('회원가입'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}