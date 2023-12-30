import 'package:flutter/widgets.dart';

class AuthModel {
  String? id;
  String? password;
  AuthModel({
    this.id,
    this.password,
  });

  AuthModel copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? password,
  }) {
    return AuthModel(
      id: id?.call() ?? this.id,
      password: password?.call() ?? this.password,
    );
  }
}
