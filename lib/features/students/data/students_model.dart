import 'dart:convert';
import 'dart:io';

import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:residency_desktop/core/constants/departments.dart';
import 'package:residency_desktop/features/core/data/user_model.dart';
import 'package:residency_desktop/utils/application_utils.dart';

import '../../../core/functions/date_time.dart';

class StudentModel {
  String? id;
  String? firstname;
  String? surname;
  String? gender;
  String? phone;
  String? block;
  String? room;
  String? department;
  String? image;
  String? role;
  String? password;
  String? level;
  bool isDeleted;
  String? academicYear;
  int? createdAt;
  StudentModel({
    this.id,
    this.firstname,
    this.surname,
    this.gender,
    this.phone,
    this.block,
    this.room,
    this.department,
    this.image,
    this.role = 'Student',
    this.password,
    this.level,
    this.isDeleted = false,
    this.academicYear,
    this.createdAt,
  });

  StudentModel copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? firstname,
    ValueGetter<String?>? surname,
    ValueGetter<String?>? gender,
    ValueGetter<String?>? phone,
    ValueGetter<String?>? block,
    ValueGetter<String?>? room,
    ValueGetter<String?>? department,
    ValueGetter<String?>? image,
    ValueGetter<String?>? role,
    ValueGetter<String?>? password,
    ValueGetter<String?>? level,
    bool? isDeleted,
    ValueGetter<String?>? academicYear,
    ValueGetter<int?>? createdAt,
  }) {
    return StudentModel(
      id: id?.call() ?? this.id,
      firstname: firstname?.call() ?? this.firstname,
      surname: surname?.call() ?? this.surname,
      gender: gender?.call() ?? this.gender,
      phone: phone?.call() ?? this.phone,
      block: block?.call() ?? this.block,
      room: room?.call() ?? this.room,
      department: department?.call() ?? this.department,
      image: image?.call() ?? this.image,
      role: role?.call() ?? this.role,
      password: password?.call() ?? this.password,
      level: level?.call() ?? this.level,
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
      'gender': gender,
      'phone': phone,
      'block': block,
      'room': room,
      'department': department,
      'image': image,
      'role': role,
      'password': password,
      'level': level,
      'isDeleted': isDeleted,
      'academicYear': academicYear,
      'createdAt': createdAt,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'],
      firstname: map['firstname'],
      surname: map['surname'],
      gender: map['gender'],
      phone: map['phone'],
      block: map['block'],
      room: map['room'],
      department: map['department'],
      image: map['image'],
      role: map['role'],
      password: map['password'],
      level: map['level'],
      isDeleted: map['isDeleted'] ?? false,
      academicYear: map['academicYear'],
      createdAt: map['createdAt']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory StudentModel.fromJson(String source) =>
      StudentModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StudentModel(id: $id, firstname: $firstname, surname: $surname, gender: $gender, phone: $phone, block: $block, room: $room, department: $department, image: $image, role: $role, password: $password, level: $level, isDeleted: $isDeleted, academicYear: $academicYear, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StudentModel &&
        other.id == id &&
        other.firstname == firstname &&
        other.surname == surname &&
        other.gender == gender &&
        other.phone == phone &&
        other.block == block &&
        other.room == room &&
        other.department == department &&
        other.image == image &&
        other.role == role &&
        other.password == password &&
        other.level == level &&
        other.isDeleted == isDeleted &&
        other.academicYear == academicYear &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstname.hashCode ^
        surname.hashCode ^
        gender.hashCode ^
        phone.hashCode ^
        block.hashCode ^
        room.hashCode ^
        department.hashCode ^
        image.hashCode ^
        role.hashCode ^
        password.hashCode ^
        level.hashCode ^
        isDeleted.hashCode ^
        academicYear.hashCode ^
        createdAt.hashCode;
  }

  factory StudentModel.fromUsers(UserModel user) {
    return StudentModel(
      id: user.id,
      firstname: user.firstname,
      surname: user.surname,
      gender: user.gender,
      phone: user.phone,
      block: user.block,
      room: user.room,
      department: user.department,
      image: user.image,
      password: user.password,
      level: user.level,
      role: user.role,
      isDeleted: user.isDeleted,
      academicYear: user.academicYear,
      createdAt: user.createdAt,
    );
  }

  List<String> excelHeadings() {
    return [
      'ID',
      'FIRSTNAME',
      'SURNAME',
      'GENDER',
      'PHONE',
      'LEVEL',
      'DEPARTMENT',
      'BLOCK',
      'ROOM',
      'ACADEMIC YEAR',
      'CREATED AT'
    ];
  }

  List<String> excelData(StudentModel item) {
    return [
      item.id ?? '',
      item.firstname ?? '',
      item.surname ?? '',
      item.gender ?? '',
      item.phone ?? '',
      item.level ?? '',
      item.department ?? '',
      item.block ?? '',
      item.room ?? '',
      item.academicYear ?? '',
      item.createdAt != null ? DateTimeAction.getDateTime(item.createdAt!) : '',
    ];
  }

  static Future<List<StudentModel>> dummyDtata() async {
    var faker = Faker();
    var list = <StudentModel>[];
    String maleImage = 'https://xsgames.co/randomusers/avatar.php?g=male';
    String femaleImage = 'https://xsgames.co/randomusers/avatar.php?g=female';
    var blk = ['Block A', 'Block B', 'Block C', 'Block D', 'Annex'];
    for (var block in blk) {
      print(
          '$block=================================================================');
      var lastChar = block.trim().substring(block.length - 1);
      for (int i = 0; i < 20; i++) {
        print("\t Room ${i + 1}");
        for (int x = 0; x < 4; x++) {
          print("\t\t Student ${x + 1}");
          var room = lastChar != 'x'
              ? '${lastChar.toUpperCase()}${i + 1}'
              : 'AA${i + 1}';
          var gender = faker.randomGenerator.element(['Male', 'Female']);
          final http.Response r = await http.get(
            Uri.parse(gender == 'Male' ? maleImage : femaleImage),
          );
          String id = faker.guid.guid().hashCode.toString();
          var file = await File('image$i.jpg').writeAsBytes(r.bodyBytes);
          var (status, data) = await AppUtils.endCodeimage(image: file);
          String? path;
          if (status) {
            path = data;
          }
          list.add(StudentModel(
              id: id,
              firstname: faker.person.firstName(),
              surname: faker.person.lastName(),
              block: block,
              level: faker.randomGenerator
                  .element(['100', '200', '300', '400', 'Graduate']),
              department: faker.randomGenerator.element(departments),
              room: room,
              phone: faker.phoneNumber
                          .us()
                          .replaceAll('-', '')
                          .replaceAll('.', '')
                          .length >
                      10
                  ? faker.phoneNumber
                      .us()
                      .replaceAll('-', '')
                      .replaceAll('.', '')
                      .substring(0, 10)
                  : faker.phoneNumber
                      .us()
                      .replaceAll('-', '')
                      .replaceAll('.', ''),
              password: id,
              image: path,
              gender: gender,
              academicYear: faker.randomGenerator.element(['2024/2025']),
              createdAt: faker.date
                  .dateTime(minYear: 2023, maxYear: 2023)
                  .millisecondsSinceEpoch));
          if (File('image$i.jpg').existsSync()) {
            File('image$i.jpg').deleteSync();
          }
        }
      }
      print('done--------------------------------------------');
    }

    return Future.value(list);
  }
}
