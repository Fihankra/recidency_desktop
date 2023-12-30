import 'dart:convert';
import 'package:flutter/widgets.dart';


class AttendanceModel {
  String? id;
  String? assistantName;
  String? assistantId;
  String? academicYear;
  String? date;
  String? action;
  String? time;
  int? createdAt;
  AttendanceModel({
    this.id,
    this.assistantName,
    this.assistantId,
    this.academicYear,
    this.date,
    this.action,
    this.time,
    this.createdAt,
  });

  AttendanceModel copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? assistantName,
    ValueGetter<String?>? assistantId,
    ValueGetter<String?>? academicYear,
    ValueGetter<String?>? date,
    ValueGetter<String?>? action,
    ValueGetter<String?>? time,
    ValueGetter<int?>? createdAt,
  }) {
    return AttendanceModel(
      id: id?.call() ?? this.id,
      assistantName: assistantName?.call() ?? this.assistantName,
      assistantId: assistantId?.call() ?? this.assistantId,
      academicYear: academicYear?.call() ?? this.academicYear,
      date: date?.call() ?? this.date,
      action: action?.call() ?? this.action,
      time: time?.call() ?? this.time,
      createdAt: createdAt?.call() ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assistantName': assistantName,
      'assistantId': assistantId,
      'academicYear': academicYear,
      'date': date,
      'action': action,
      'time': time,
      'createdAt': createdAt,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'],
      assistantName: map['assistantName'],
      assistantId: map['assistantId'],
      academicYear: map['academicYear'],
      date: map['date'],
      action: map['action'],
      time: map['time'],
      createdAt: map['createdAt']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory AttendanceModel.fromJson(String source) =>
      AttendanceModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AttendanceModel(id: $id, assistantName: $assistantName, assistantId: $assistantId, academicYear: $academicYear, date: $date, action: $action, time: $time, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AttendanceModel &&
      other.id == id &&
      other.assistantName == assistantName &&
      other.assistantId == assistantId &&
      other.academicYear == academicYear &&
      other.date == date &&
      other.action == action &&
      other.time == time &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      assistantName.hashCode ^
      assistantId.hashCode ^
      academicYear.hashCode ^
      date.hashCode ^
      action.hashCode ^
      time.hashCode ^
      createdAt.hashCode;
  }

}
