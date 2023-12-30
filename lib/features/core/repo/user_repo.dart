import 'package:residency_desktop/features/core/data/user_model.dart';

abstract class UserRepo {
  

  Future<(Exception?, UserModel?)> updateUser(Map<String,dynamic> user);


  //login user
  Future<(Exception?, UserModel?)> loginUser(String id, String password);
  Future<void> creatAdmin();
  

  
} 