import 'dart:convert';
import 'package:flutter/foundation.dart';


class SettingsModel {
  String? id;
  String? hallName;
  String? targetGender;
  String? hallLogo;
  String? academicYear;
  int? createdAt;
  SettingsModel({
    this.id,
    this.hallName,
    this.targetGender,
    this.hallLogo,
    this.academicYear,
    this.createdAt,
  });
 

  SettingsModel copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? hallName,
    ValueGetter<String?>? targetGender,
    ValueGetter<String?>? hallLogo,
    ValueGetter<String?>? academicYear,
    ValueGetter<int?>? createdAt,
  }) {
    return SettingsModel(
      id: id?.call() ?? this.id,
      hallName: hallName?.call() ?? this.hallName,
      targetGender: targetGender?.call() ?? this.targetGender,
      hallLogo: hallLogo?.call() ?? this.hallLogo,
      academicYear: academicYear?.call() ?? this.academicYear,
      createdAt: createdAt?.call() ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hallName': hallName,
      'targetGender': targetGender,
      'hallLogo': hallLogo,
      'academicYear': academicYear,
      'createdAt': createdAt,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      id: map['id'],
      hallName: map['hallName'],
      targetGender: map['targetGender'],
      hallLogo: map['hallLogo'],
      academicYear: map['academicYear'],
      createdAt: map['createdAt']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingsModel.fromJson(String source) => SettingsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SettingsModel(id: $id, hallName: $hallName, targetGender: $targetGender, hallLogo: $hallLogo, academicYear: $academicYear, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SettingsModel &&
      other.id == id &&
      other.hallName == hallName &&
      other.targetGender == targetGender &&
      other.hallLogo == hallLogo &&
      other.academicYear == academicYear &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      hallName.hashCode ^
      targetGender.hashCode ^
      hallLogo.hashCode ^
      academicYear.hashCode ^
      createdAt.hashCode;
  }
}
