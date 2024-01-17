import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/functions/date_time.dart';

class MessageModel {
  String? id;
  String? senderId;
  String? message;
  bool isDeleted;
  String? status;
  List<Map<String, dynamic>>? recipients;
  List<Map<String, dynamic>>? responseData;
  String? accademicYear;
  int? createdAt;
  MessageModel({
    this.id,
    this.senderId,
    this.message,
    this.isDeleted = false,
    this.status,
    this.recipients,
    this.responseData,
    this.accademicYear,
    this.createdAt,
  });

  MessageModel copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? senderId,
    ValueGetter<String?>? message,
    bool? isDeleted,
    ValueGetter<String?>? status,
    ValueGetter<List<Map<String, dynamic>>?>? recipients,
    ValueGetter<List<Map<String, dynamic>>?>? responseData,
    ValueGetter<String?>? accademicYear,
    ValueGetter<int?>? createdAt,
  }) {
    return MessageModel(
      id: id != null ? id() : this.id,
      senderId: senderId != null ? senderId() : this.senderId,
      message: message != null ? message() : this.message,
      isDeleted: isDeleted ?? this.isDeleted,
      status: status != null ? status() : this.status,
      recipients: recipients != null ? recipients() : this.recipients,
      responseData: responseData != null ? responseData() : this.responseData,
      accademicYear:
          accademicYear != null ? accademicYear() : this.accademicYear,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'message': message,
      'isDeleted': isDeleted,
      'status': status,
      'recipients': recipients,
      'responseData': responseData,
      'accademicYear': accademicYear,
      'createdAt': createdAt,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      senderId: map['senderId'],
      message: map['message'],
      isDeleted: map['isDeleted'] ?? false,
      status: map['status'],
      recipients: map['recipients'] != null
          ? List<Map<String, dynamic>>.from(map['recipients']?.map((x) => x))
          : null,
      responseData: map['responseData'] != null
          ? List<Map<String, dynamic>>.from(map['responseData']?.map((x) => x))
          : null,
      accademicYear: map['accademicYear'],
      createdAt: map['createdAt']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MessageModel(id: $id, senderId: $senderId, message: $message, isDeleted: $isDeleted, status: $status, recipients: $recipients, responseData: $responseData, accademicYear: $accademicYear, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageModel &&
        other.id == id &&
        other.senderId == senderId &&
        other.message == message &&
        other.isDeleted == isDeleted &&
        other.status == status &&
        listEquals(other.recipients, recipients) &&
        listEquals(other.responseData, responseData) &&
        other.accademicYear == accademicYear &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        senderId.hashCode ^
        message.hashCode ^
        isDeleted.hashCode ^
        status.hashCode ^
        recipients.hashCode ^
        responseData.hashCode ^
        accademicYear.hashCode ^
        createdAt.hashCode;
  }

  List<String> excelHeadings() {
    return [
      'id',
      'senderId',
      'message',
      'status',
      'accademicYear',
      'createdAt',
    ];
  }

  List<String> excelData(MessageModel item) {
    return [
      item.id ?? '',
      item.senderId ?? '',
      item.message ?? '',
      item.status ?? '',
      item.accademicYear ?? '',
      item.createdAt != null ? DateTimeAction.getDateTime(item.createdAt!) : ''
    ];
  }
}
