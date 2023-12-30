import 'dart:convert';
import 'package:flutter/foundation.dart';


class ComplaintsModel {
  String? id;
  String? title;
  String? description;
  String? studentId;
  String? studentName;
  String? studentPhone;
  String? studentImage;
  String? status;
  String? roomNumber;
  String? type;
  String? severity;
  String? academicYear;
  List<String>? images;
  int? createdAt;
  ComplaintsModel({
    this.id,
    this.title,
    this.description,
    this.studentId,
    this.studentName,
    this.studentPhone,
    this.studentImage,
    this.status,
    this.roomNumber,
    this.type,
    this.severity,
    this.academicYear,
    this.images,
    this.createdAt,
  });

  ComplaintsModel copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? title,
    ValueGetter<String?>? description,
    ValueGetter<String?>? studentId,
    ValueGetter<String?>? studentName,
    ValueGetter<String?>? studentPhone,
    ValueGetter<String?>? studentImage,
    ValueGetter<String?>? status,
    ValueGetter<String?>? roomNumber,
    ValueGetter<String?>? type,
    ValueGetter<String?>? severity,
    ValueGetter<String?>? academicYear,
    ValueGetter<List<String>?>? images,
    ValueGetter<int?>? createdAt,
  }) {
    return ComplaintsModel(
      id: id?.call() ?? this.id,
      title: title?.call() ?? this.title,
      description: description?.call() ?? this.description,
      studentId: studentId?.call() ?? this.studentId,
      studentName: studentName?.call() ?? this.studentName,
      studentPhone: studentPhone?.call() ?? this.studentPhone,
      studentImage: studentImage?.call() ?? this.studentImage,
      status: status?.call() ?? this.status,
      roomNumber: roomNumber?.call() ?? this.roomNumber,
      type: type?.call() ?? this.type,
      severity: severity?.call() ?? this.severity,
      academicYear: academicYear?.call() ?? this.academicYear,
      images: images?.call() ?? this.images,
      createdAt: createdAt?.call() ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'studentId': studentId,
      'studentName': studentName,
      'studentPhone': studentPhone,
      'studentImage': studentImage,
      'status': status,
      'roomNumber': roomNumber,
      'type': type,
      'severity': severity,
      'academicYear': academicYear,
      'images': images,
      'createdAt': createdAt,
    };
  }

  factory ComplaintsModel.fromMap(Map<String, dynamic> map) {
    return ComplaintsModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      studentId: map['studentId'],
      studentName: map['studentName'],
      studentPhone: map['studentPhone'],
      studentImage: map['studentImage'],
      status: map['status'],
      roomNumber: map['roomNumber'],
      type: map['type'],
      severity: map['severity'],
      academicYear: map['academicYear'],
      images: List<String>.from(map['images']),
      createdAt: map['createdAt']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ComplaintsModel.fromJson(String source) =>
      ComplaintsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ComplaintsModel(id: $id, title: $title, description: $description, studentId: $studentId, studentName: $studentName, studentPhone: $studentPhone, studentImage: $studentImage, status: $status, roomNumber: $roomNumber, type: $type, severity: $severity, academicYear: $academicYear, images: $images, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ComplaintsModel &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.studentId == studentId &&
      other.studentName == studentName &&
      other.studentPhone == studentPhone &&
      other.studentImage == studentImage &&
      other.status == status &&
      other.roomNumber == roomNumber &&
      other.type == type &&
      other.severity == severity &&
      other.academicYear == academicYear &&
      listEquals(other.images, images) &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      studentId.hashCode ^
      studentName.hashCode ^
      studentPhone.hashCode ^
      studentImage.hashCode ^
      status.hashCode ^
      roomNumber.hashCode ^
      type.hashCode ^
      severity.hashCode ^
      academicYear.hashCode ^
      images.hashCode ^
      createdAt.hashCode;
  }

   List<String>excelHeadings() {
    return [
      'Title',
      'Description',
      'Student Name',
      'Student Phone',
      'Room Number',
      'Type',
      'Severity',
      'Status',
      'Academic Year',
      'Created At',
    ];
  }

  List<String> excelData(ComplaintsModel item) {
    return [
      item.title!,
      item.description!,
      item.studentName!,
      item.studentPhone!,
      item.roomNumber!,
      item.type!,
      item.severity!,
      item.status!,
      item.academicYear!,
      item.createdAt.toString(),
    ];

  }


}
