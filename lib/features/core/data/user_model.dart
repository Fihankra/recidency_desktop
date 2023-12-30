import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:residency_desktop/features/staffs/data/staff_model.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';

class UserModel {
  String? id;
  String? firstname;
  String? surname;
  String? email;
  String? phone;
  String? block;
  String? room;
  String? department;
  String? image;
  String? password;
  String? level;
  String? gender;
  String? role;
  String? question1;
  String? answer1;
  String? question2;
  String? answer2;
  bool isDeleted;
  String? academicYear;
  int? createdAt;
  UserModel({
    this.id,
    this.firstname,
    this.surname,
    this.email,
    this.phone,
    this.block,
    this.room,
    this.department,
    this.image,
    this.password,
    this.level,
    this.gender,
    this.role,
    this.question1,
    this.answer1,
    this.question2,
    this.answer2,
    this.isDeleted = false,
    this.academicYear,
    this.createdAt,
  });

  UserModel copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? firstname,
    ValueGetter<String?>? surname,
    ValueGetter<String?>? email,
    ValueGetter<String?>? phone,
    ValueGetter<String?>? block,
    ValueGetter<String?>? room,
    ValueGetter<String?>? department,
    ValueGetter<String?>? image,
    ValueGetter<String?>? password,
    ValueGetter<String?>? level,
    ValueGetter<String?>? gender,
    ValueGetter<String?>? role,
    ValueGetter<String?>? question1,
    ValueGetter<String?>? answer1,
    ValueGetter<String?>? question2,
    ValueGetter<String?>? answer2,
    bool? isDeleted,
    ValueGetter<String?>? academicYear,
    ValueGetter<int?>? createdAt,
  }) {
    return UserModel(
      id: id?.call() ?? this.id,
      firstname: firstname?.call() ?? this.firstname,
      surname: surname?.call() ?? this.surname,
      email: email?.call() ?? this.email,
      phone: phone?.call() ?? this.phone,
      block: block?.call() ?? this.block,
      room: room?.call() ?? this.room,
      department: department?.call() ?? this.department,
      image: image?.call() ?? this.image,
      password: password?.call() ?? this.password,
      level: level?.call() ?? this.level,
      gender: gender?.call() ?? this.gender,
      role: role?.call() ?? this.role,
      question1: question1?.call() ?? this.question1,
      answer1: answer1?.call() ?? this.answer1,
      question2: question2?.call() ?? this.question2,
      answer2: answer2?.call() ?? this.answer2,
      isDeleted: isDeleted ?? this.isDeleted,
      academicYear: academicYear?.call() ?? this.academicYear,
      createdAt: createdAt?.call() ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstname': firstname,
      'surname': surname,
      'email': email,
      'phone': phone,
      'block': block,
      'room': room,
      'department': department,
      'image': image,
      'password': password,
      'level': level,
      'gender': gender,
      'role': role,
      'question1': question1,
      'answer1': answer1,
      'question2': question2,
      'answer2': answer2,
      'isDeleted': isDeleted,
      'academicYear': academicYear,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      firstname: map['firstname'],
      surname: map['surname'],
      email: map['email'],
      phone: map['phone'],
      block: map['block'],
      room: map['room'],
      department: map['department'],
      image: map['image'],
      password: map['password'],
      level: map['level'],
      gender: map['gender'],
      role: map['role'],
      question1: map['question1'],
      answer1: map['answer1'],
      question2: map['question2'],
      answer2: map['answer2'],
      isDeleted: map['isDeleted'] ?? false,
      academicYear: map['academicYear'],
      createdAt: map['createdAt']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(id: $id, firstname: $firstname, surname: $surname, email: $email, phone: $phone, block: $block, room: $room, department: $department, image: $image, password: $password, level: $level, gender: $gender, role: $role, question1: $question1, answer1: $answer1, question2: $question2, answer2: $answer2, isDeleted: $isDeleted, academicYear: $academicYear, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.firstname == firstname &&
        other.surname == surname &&
        other.email == email &&
        other.phone == phone &&
        other.block == block &&
        other.room == room &&
        other.department == department &&
        other.image == image &&
        other.password == password &&
        other.level == level &&
        other.gender == gender &&
        other.role == role &&
        other.question1 == question1 &&
        other.answer1 == answer1 &&
        other.question2 == question2 &&
        other.answer2 == answer2 &&
        other.isDeleted == isDeleted &&
        other.academicYear == academicYear &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstname.hashCode ^
        surname.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        block.hashCode ^
        room.hashCode ^
        department.hashCode ^
        image.hashCode ^
        password.hashCode ^
        level.hashCode ^
        gender.hashCode ^
        role.hashCode ^
        question1.hashCode ^
        answer1.hashCode ^
        question2.hashCode ^
        answer2.hashCode ^
        isDeleted.hashCode ^
        academicYear.hashCode ^
        createdAt.hashCode;
  }

  Map<String, dynamic> toUpdatePassword() {
    return {
      'id': id,
      'password': password,
      'question1': question1,
      'answer1': answer1,
      'question2': question2,
      'answer2': answer2,
    };
  }

  factory UserModel.fromAssistant(StaffModel assistantModel) {
    return UserModel().copyWith(
      id: () => assistantModel.id,
      firstname: () => assistantModel.firstname,
      surname: () => assistantModel.surname,
      email: () => assistantModel.email,
      phone: () => assistantModel.phone,
      password: () => assistantModel.password,
      gender: () => assistantModel.gender,
      image: () => assistantModel.image,
      role: () => assistantModel.role,
      question1: () => assistantModel.question1,
      answer1: () => assistantModel.answer1,
      question2: () => assistantModel.question2,
      answer2: () => assistantModel.answer2,
      isDeleted: assistantModel.isDeleted,
      //academicYear: () => assistantModel.academicYear,
      createdAt: () => assistantModel.createdAt,
    );
  }

  factory UserModel.fromStudent(StudentModel student) {
    return UserModel().copyWith(
      id: () => student.id,
      firstname: () => student.firstname,
      surname: () => student.surname,
      phone: () => student.phone,
      password: () => student.password,
      gender: () => student.gender,
      image: () => student.image,
      role: () => student.role,
      block: () => student.block,
      room: () => student.room,
      department: () => student.department,
      level: () => student.level,
      isDeleted: student.isDeleted,
      academicYear: () => student.academicYear,
      createdAt: () => student.createdAt,
    );
  }
}
