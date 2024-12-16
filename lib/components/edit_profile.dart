import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _profileImageUrl;

  bool _isLoading = true;
  bool _isImageUploading = false;
  late String _uid;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
      try {
        final snapshot = await FirebaseFirestore.instance.collection('users').doc(_uid).get();

        if (snapshot.exists) {
          final data = snapshot.data()!;
          setState(() {
            _nameController.text = data['name'] ?? user.displayName ?? '';
            _ageController.text = data['age'] ?? '';
            _heightController.text = data['height'] ?? '';
            _weightController.text = data['weight'] ?? '';
            _profileImageUrl = data['photoUrl'] ?? user.photoURL;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          _isLoading = false;
        });
        _showCenteredMessage('사용자 데이터를 불러오지 못했습니다.');
      }
    }
  }

  Future<void> _updateUserData() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'name': _nameController.text,
        'age': _ageController.text,
        'height': _heightController.text,
        'weight': _weightController.text,
      });

      Navigator.pop(context, 'updated');

      _showCenteredMessage('프로필이 업데이트 되었습니다.');
    } catch (e) {
      print('Error updating user data: $e');
      _showCenteredMessage('프로필 업데이트에 실패했습니다. 다시 시도해주세요.');
    }
  }

  // 화면 정중앙에 메시지 출력
  void _showCenteredMessage(String message) {
    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black54, // 반투명 배경
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8), // 메시지 배경 반투명 검정
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white, // 텍스트 흰색
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    overlayState!.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Text(
              "프로필 수정",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _updateUserData,
              child: Text(
                "완료",
                style: TextStyle(color: Color(0xFFF6C2FF2), fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 사진
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                    if (_isImageUploading)
                      Positioned.fill(
                        child: CircularProgressIndicator(),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        child: CircleAvatar(
                          backgroundColor: Color(0xFFF6C2FF2),
                          radius: 20,
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "닉네임",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: "나이",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: "키 (cm)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: "몸무게 (kg)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
