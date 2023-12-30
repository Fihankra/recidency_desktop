import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:residency_desktop/features/core/usecase/user_usecase.dart';

final dbConnectionProvider = FutureProvider<Db?>((ref) async {
  String mongoLocalUri = 'mongodb://localhost:27017/residency';
  String? mongoIpUri = 'mongodb://192.168.10.10:27017/residency';
  //use ip address of 192.168.10.10 if connection is from host machine
  try {
    var db = await Db.create(mongoLocalUri);
    await db.open();
    //check if connection is from host machine
    if (db.state == State.open) {
      ref.read(dbProvider.notifier).state = db;
      await UserUseCase(db: db).creatAdmin();
      return Future.value(db);
    } else {
      db = await Db.create(mongoIpUri);
      await db.open();
      if (db.state == State.open) {
        ref.read(dbProvider.notifier).state = db;
        return Future.value(db);
      } 
    }

  } catch (e) { 
    return Future.error(e);
  }
  return null;
});


final dbProvider = StateProvider<Db?>((ref) {
  return null;
});