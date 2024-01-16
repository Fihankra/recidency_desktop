import 'package:dio/dio.dart';
import 'package:residency_desktop/features/core/data/user_model.dart';
import 'package:residency_desktop/features/core/repo/user_repo.dart';

class UserUseCase extends UserRepo {
  final Dio dio;

  UserUseCase({required this.dio});
  @override
  Future<(Exception?, UserModel?)> updateUser(Map<String, dynamic> user) async {
    try {
      var body = {
        'password': user['password'],
        'question1': user['question1'],
        'answer1': user['answer1'],
        'question2': user['question2'],
        'answer2': user['answer2'],
        'id': user['id']
      };
      var response = await dio.put('auth/updatePassword', data: body);
      if (response.statusCode == 200) {
        if (response.data['success']) {
          var user = response.data['data'];
          return Future.value((null, UserModel.fromMap(user)));
        } else {
          return Future.value((Exception(response.data['message']), null));
        }
      } else {
        return Future.value((Exception('Error updating user'), null));
      }
    } catch (e) {
      return Future.value((Exception(e.toString()), null));
    }
  }

  @override
  Future<(Exception?, UserModel?)> loginUser(String id, String password) async {
    try {
      var body = {
        'id': id,
        'password': password,
      };
      var response = await dio.post('auth/login', data: body);
      if (response.statusCode == 200) {
        if (response.data['success']) {
          var user = response.data['data'];
          return Future.value((null, UserModel.fromMap(user)));
        } else {
          return Future.value((Exception(response.data['message']), null));
        }
      } else {
        return Future.value((Exception('Error logging in'), null));
      }
    } catch (e) {
      return Future.value((Exception(e.toString()), null));
    }
  }
}
