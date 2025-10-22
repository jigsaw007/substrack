import 'package:flutter/material.dart';
import '../ui/screens/home_screen.dart';
import 'package:flutter/foundation.dart';

final router = RouterConfig<Object>(routerDelegate: _Delegate());

class _Delegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  final GlobalKey<NavigatorState> _key = GlobalKey<NavigatorState>();
  @override
  GlobalKey<NavigatorState> get navigatorKey => _key;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _key,
      pages: const [MaterialPage(child: HomeScreen())],
      onPopPage: (route, result) => route.didPop(result),
    );
  }

  @override
  Future<bool> popRoute() => SynchronousFuture(false);
  @override
  Future<void> setNewRoutePath(configuration) async {}
}
