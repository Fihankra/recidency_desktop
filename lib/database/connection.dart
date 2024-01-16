import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongo_dart/mongo_dart.dart';

final serverFuture = FutureProvider((ref) async {
  var dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
    ),
  );
  try {
    const String mainServer = 'http://192.168.10.1:9000/';
    var mainDio = await dio.get(mainServer);
    if (mainDio.statusCode == 200) {
      dio.options.baseUrl = mainServer;
      ref.read(serverProvider.notifier).state = dio;
    }
  } catch (_) {
    try{
    const String backupServer = 'http://localhost:9000/';
    var backupDio = await dio.get(backupServer);
    if (backupDio.statusCode == 200) {
      dio.options.baseUrl = backupServer;
      ref.read(serverProvider.notifier).state = dio;
    }
    }catch(_){
    }
  }
});

final serverProvider = StateProvider<Dio?>((ref) {
  return null;
});



final dbProvider = StateProvider<Db?>((ref) {
  return null;
});
