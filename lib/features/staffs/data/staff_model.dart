import 'dart:convert';
import 'dart:io';
import 'package:faker/faker.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:residency_desktop/core/functions/date_time.dart';
import 'package:residency_desktop/features/core/data/user_model.dart';
import 'package:residency_desktop/utils/application_utils.dart';

class StaffModel {
  String? id;
  String? firstname;
  String? surname;
  String? email;
  String? phone;
  String? password;
  String? gender;
  String? image;
  String? role;
  String? question1;
  String? answer1;
  String? question2;
  String? answer2;
  bool isDeleted;
  // String? academicYear;
  int? createdAt;
  StaffModel({
    this.id,
    this.firstname,
    this.surname,
    this.email,
    this.phone,
    this.password,
    this.gender,
    this.image,
    this.role,
    this.question1,
    this.answer1,
    this.question2,
    this.answer2,
    this.isDeleted = false,
    this.createdAt,
  });

  StaffModel copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? firstname,
    ValueGetter<String?>? surname,
    ValueGetter<String?>? email,
    ValueGetter<String?>? phone,
    ValueGetter<String?>? password,
    ValueGetter<String?>? gender,
    ValueGetter<String?>? image,
    ValueGetter<String?>? role,
    ValueGetter<String?>? question1,
    ValueGetter<String?>? answer1,
    ValueGetter<String?>? question2,
    ValueGetter<String?>? answer2,
    bool? isDeleted,
    ValueGetter<int?>? createdAt,
  }) {
    return StaffModel(
      id: id?.call() ?? this.id,
      firstname: firstname?.call() ?? this.firstname,
      surname: surname?.call() ?? this.surname,
      email: email?.call() ?? this.email,
      phone: phone?.call() ?? this.phone,
      password: password?.call() ?? this.password,
      gender: gender?.call() ?? this.gender,
      image: image?.call() ?? this.image,
      role: role?.call() ?? this.role,
      question1: question1?.call() ?? this.question1,
      answer1: answer1?.call() ?? this.answer1,
      question2: question2?.call() ?? this.question2,
      answer2: answer2?.call() ?? this.answer2,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt?.call() ?? this.createdAt,
    );
  }

  factory StaffModel.fromUsers(UserModel user) {
    return StaffModel().copyWith(
      id: () => user.id,
      firstname: () => user.firstname,
      surname: () => user.surname,
      email: () => user.email,
      phone: () => user.phone,
      password: () => user.password,
      gender: () => user.gender,
      image: () => user.image,
      role: () => user.role ,
      question1: () => user.question1,
      answer1: () => user.answer1,
      question2: () => user.question2,
      answer2: () => user.answer2,
      isDeleted: user.isDeleted,
      // academicYear: () => user.academicYear,
      createdAt: () => user.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstname': firstname,
      'surname': surname,
      'email': email,
      'phone': phone,
      'password': password,
      'gender': gender,
      'image': image,
      'role': role,
      'question1': question1,
      'answer1': answer1,
      'question2': question2,
      'answer2': answer2,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
    };
  }

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      id: map['id'],
      firstname: map['firstname'],
      surname: map['surname'],
      email: map['email'],
      phone: map['phone'],
      password: map['password'],
      gender: map['gender'],
      image: map['image'],
      role: map['role'],
      question1: map['question1'],
      answer1: map['answer1'],
      question2: map['question2'],
      answer2: map['answer2'],
      isDeleted: map['isDeleted'] ?? false,
      createdAt: map['createdAt']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory StaffModel.fromJson(String source) =>
      StaffModel.fromMap(json.decode(source));

  List<String> excelHeadings() {
    return [
      'ID',
      'FIRSTNAME',
      'SURNAME',
      'GENDER',
      'ROLE',
      'EMAIL',
      'PHONE',
      //'ACADEMIC YEAR',
      'CREATED AT'
    ];
  }

  List<String> excelData(StaffModel item) {
    return [
      item.id ?? '',
      item.firstname ?? '',
      item.surname ?? '',
      item.gender ?? '',
      item.role ?? '',
      item.email ?? '',
      item.phone ?? '',
      // item.academicYear ?? '',
      item.createdAt != null ? DateTimeAction.getDateTime(item.createdAt!) : '',
    ];
  }

  static Future<List<StaffModel>> dummyDtata() async {
    var faker = Faker();
    var list = <StaffModel>[];
    for (int i = 0; i < 100; i++) {
      String id = faker.guid.guid().hashCode.toString();
      String image = faker.image.image();
      final http.Response r = await http.get(
        Uri.parse(image),
      );
      var folder = await AppUtils.createFolderInAppDocDir('assistants');
      var filename = id.replaceAll(' ', '_');
      var path = '$folder/$filename.jpg';
      try {
        File(path).writeAsBytesSync(r.bodyBytes);
      } catch (_) {}
      list.add(StaffModel(
          id: id,
          firstname: faker.person.firstName(),
          surname: faker.person.lastName(),
          email: faker.internet.email(),
          phone: faker.phoneNumber.us(),
          password: AppUtils.hashPassword(id),
          image: path,
          gender: faker.randomGenerator.element(['Male', 'Female']),
          // academicYear: faker.randomGenerator
          //     .element(['2021/2022', '2022/2023', '2023/2024', '2024/2025']),
          createdAt: faker.date
              .dateTime(minYear: 2023, maxYear: 2023)
              .millisecondsSinceEpoch));
    }

    return Future.value(list);
  }

  @override
  String toString() {
    return 'StaffModel(id: $id, firstname: $firstname, surname: $surname, email: $email, phone: $phone, password: $password, gender: $gender, image: $image, role: $role, question1: $question1, answer1: $answer1, question2: $question2, answer2: $answer2, isDeleted: $isDeleted, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is StaffModel &&
      other.id == id &&
      other.firstname == firstname &&
      other.surname == surname &&
      other.email == email &&
      other.phone == phone &&
      other.password == password &&
      other.gender == gender &&
      other.image == image &&
      other.role == role &&
      other.question1 == question1 &&
      other.answer1 == answer1 &&
      other.question2 == question2 &&
      other.answer2 == answer2 &&
      other.isDeleted == isDeleted &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      firstname.hashCode ^
      surname.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      password.hashCode ^
      gender.hashCode ^
      image.hashCode ^
      role.hashCode ^
      question1.hashCode ^
      answer1.hashCode ^
      question2.hashCode ^
      answer2.hashCode ^
      isDeleted.hashCode ^
      createdAt.hashCode;
  }
}
