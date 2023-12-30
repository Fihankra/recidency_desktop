import 'package:mongo_dart/mongo_dart.dart';
import 'package:residency_desktop/core/constants/role_enum.dart';
import 'package:residency_desktop/features/core/data/user_model.dart';
import 'package:residency_desktop/features/core/repo/user_repo.dart';
import 'package:residency_desktop/utils/application_utils.dart';

class UserUseCase extends UserRepo {
  final Db db;

  UserUseCase({required this.db});
  @override
  Future<(Exception?, UserModel?)> updateUser(Map<String, dynamic> user) async {
    try {
      if (db.state != State.open) {
        db.open();
      }
      var coll = db.collection('users');
      var operation = ModifierBuilder();
      operation.set('password', user['password']);
      //questions and answers
      operation.set('question1', user['question1']);
      operation.set('answer1', user['answer1']);
      operation.set('question2', user['question2']);
      operation.set('answer2', user['answer2']);
      var modify = operation;
      await coll.updateOne(where.eq('id', user['id']), modify, upsert: true);
      var getUser = await coll.findOne(where.eq('id', user['id']));
      return Future.value((null, UserModel.fromMap(getUser!)));
    } catch (e) {
      return Future.value((Exception(e.toString()), null));
    }
  }

  @override
  Future<(Exception?, UserModel?)> loginUser(String id, String password) async {
    try {
      if (db.state != State.open) {
        await db.open();
      }
      var coll = db.collection('users');
      Map<String, dynamic>? data =
          await coll.findOne(where.eq('id', id).eq('isDeleted', false));
      if (data == null) {
        return Future.value((Exception('User not found'), null));
      }
      var user = UserModel.fromMap(data);
      if (AppUtils.comparePassword(password, user.password!)) {
        return Future.value((null, UserModel.fromMap(data)));
      } else {
        return Future.value((Exception('Password is incorrect'), null));
      }
    } catch (e) {
      return Future.value((Exception(e.toString()), null));
    }
  }

  @override
  Future<void> creatAdmin() async {
    try {
      if (db.state != State.open) {
        await db.open();
      }
      var coll = db.collection('users');
      Map<String, dynamic>? data =
          await coll.findOne(where.eq('role', 'admin'));
      if (data == null) {
        var user = UserModel(
          id: 'admin',
          firstname: 'admin',
          surname: 'admin',
          role: Role.hallAdmin,
          password: AppUtils.hashPassword('admin'),
        );
        await coll.insert(user.toMap());
      }
    } catch (_) {
    }
  }
}
