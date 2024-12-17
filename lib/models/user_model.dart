import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl; // nullable로 설정
  final String age;
  final String height;
  final String weight;
  final String gender;
  final String fcmToken;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.fcmToken,
    this.photoUrl, // nullable로 설정
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      photoUrl: user.photoURL,
      age: user.age ??'',
      height: user.height ??'',
      weight: user.weight ??'',
      gender: user.gender ??'',
      fcmToken: user.fcmToken ??'',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fcm_token': fcmToken,
      'email': email,
      'name': name,
      'photoUrl': photoUrl, // photoUrl을 추가
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
    };
  }
}

extension on User {
  get age => null;

  get height => null;

  get weight => null;

  get gender => null;

  get fcmToken => null;
}