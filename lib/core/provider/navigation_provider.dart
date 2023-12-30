import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residency_desktop/config/router/router_info.dart';

final navProvider = StateProvider<String>((ref) {
  return RouterInfo.dashboardRoute.routeName;
});
