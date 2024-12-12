import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String filePath = 'profile_images/$_uid.jpg';
      File file = File(pickedFile.path);

      setState(() {
        _isImageUploading = true;
      });

      try {
        UploadTask uploadTask = FirebaseStorage.instance.ref(filePath).putFile(file);
        await uploadTask.whenComplete(() async {
          String downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();
          setState(() {
            _profileImageUrl = downloadUrl;
            _isImageUploading = false;
          });

          await FirebaseFirestore.instance.collection('users').doc(_uid).update({
            'photoUrl': downloadUrl,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('프로필 사진이 업데이트되었습니다.')),
          );
        });
      } catch (e) {
        setState(() {
          _isImageUploading = false;
        });
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 사진 업로드에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 데이터를 불러오지 못했습니다.')),
        );
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

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필이 업데이트되었습니다.')),
      );
    } catch (e) {
      print('Error updating user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 업데이트에 실패했습니다. 다시 시도해주세요.')),
      );
    }
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
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
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
                        onTap: _pickImage,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
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