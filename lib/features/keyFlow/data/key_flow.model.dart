import 'dart:convert';

import 'package:flutter/widgets.dart';

class KeyLogModel {
  String? id;
  String? assistantId;
  String? assistantName;
  String? assistantImage;
  String? studentName;
  String? studentPhone;
  String? studentId;
  String? studentImage;
  String? roomNumber;
  String? activity;
  String? academicYear;
  String? date;
  String? time;
  int? createdAt;
  KeyLogModel({
    this.id,
    this.assistantId,
    this.assistantName,
    this.assistantImage,
    this.studentName,
    this.studentPhone,
    this.studentId,
    this.studentImage,
    this.roomNumber,
    this.activity,
    this.academicYear,
    this.date,
    this.time,
    this.createdAt,
  });

  KeyLogModel copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? assistantId,
    ValueGetter<String?>? assistantName,
    ValueGetter<String?>? assistantImage,
    ValueGetter<String?>? studentName,
    ValueGetter<String?>? studentPhone,
    ValueGetter<String?>? studentId,
    ValueGetter<String?>? studentImage,
    ValueGetter<String?>? roomNumber,
    ValueGetter<String?>? activity,
    ValueGetter<String?>? academicYear,
    ValueGetter<String?>? date,
    ValueGetter<String?>? time,
    ValueGetter<int?>? createdAt,
  }) {
    return KeyLogModel(
      id: id?.call() ?? this.id,
      assistantId: assistantId?.call() ?? this.assistantId,
      assistantName: assistantName?.call() ?? this.assistantName,
      assistantImage: assistantImage?.call() ?? this.assistantImage,
      studentName: studentName?.call() ?? this.studentName,
      studentPhone: studentPhone?.call() ?? this.studentPhone,
      studentId: studentId?.call() ?? this.studentId,
      studentImage: studentImage?.call() ?? this.studentImage,
      roomNumber: roomNumber?.call() ?? this.roomNumber,
      activity: activity?.call() ?? this.activity,
      academicYear: academicYear?.call() ?? this.academicYear,
      date: date?.call() ?? this.date,
      time: time?.call() ?? this.time,
      createdAt: createdAt?.call() ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assistantId': assistantId,
      'assistantName': assistantName,
      'assistantImage': assistantImage,
      'studentName': studentName,
      'studentPhone': studentPhone,
      'studentId': studentId,
      'studentImage': studentImage,
      'roomNumber': roomNumber,
      'activity': activity,
      'academicYear': academicYear,
      'date': date,
      'time': time,
      'createdAt': createdAt,
    };
  }

  factory KeyLogModel.fromMap(Map<String, dynamic> map) {
    return KeyLogModel(
      id: map['id'],
      assistantId: map['assistantId'],
      assistantName: map['assistantName'],
      assistantImage: map['assistantImage'],
      studentName: map['studentName'],
      studentPhone: map['studentPhone'],
      studentId: map['studentId'],
      studentImage: map['studentImage'],
      roomNumber: map['roomNumber'],
      activity: map['activity'],
      academicYear: map['academicYear'],
      date: map['date'],
      time: map['time'],
      createdAt: map['createdAt']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory KeyLogModel.fromJson(String source) =>
      KeyLogModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'KeyLogModel(id: $id, assistantId: $assistantId, assistantName: $assistantName, assistantImage: $assistantImage, studentName: $studentName, studentPhone: $studentPhone, studentId: $studentId, studentImage: $studentImage, roomNumber: $roomNumber, activity: $activity, academicYear: $academicYear, date: $date, time: $time, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is KeyLogModel &&
      other.id == id &&
      other.assistantId == assistantId &&
      other.assistantName == assistantName &&
      other.assistantImage == assistantImage &&
      other.studentName == studentName &&
      other.studentPhone == studentPhone &&
      other.studentId == studentId &&
      other.studentImage == studentImage &&
      other.roomNumber == roomNumber &&
      other.activity == activity &&
      other.academicYear == academicYear &&
      other.date == date &&
      other.time == time &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      assistantId.hashCode ^
      assistantName.hashCode ^
      assistantImage.hashCode ^
      studentName.hashCode ^
      studentPhone.hashCode ^
      studentId.hashCode ^
      studentImage.hashCode ^
      roomNumber.hashCode ^
      activity.hashCode ^
      academicYear.hashCode ^
      date.hashCode ^
      time.hashCode ^
      createdAt.hashCode;
  }

  List<String> excelHeadings() {
    return [
      'Assistant Name',
      'Student Name',
      'Student Phone',
      'Room Number',
      'Activity',
      'Date',
      'Time',
    ];
  }

  List<String> excelData(KeyLogModel item) {
    return [
      item.assistantName!,
      item.studentName!,
      item.studentPhone!,
      item.roomNumber!,
      item.activity!,
      item.date!,
      item.time!,
    ];
  }
}
