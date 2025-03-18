import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:login_demo/features/canvas_painter/drawing_screen.dart';

import '../../features/error/error_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'route_path.dart';

part 'routes.g.dart';

class ErrorRoute extends GoRouteData {
  ErrorRoute({required this.error});
  final Exception error;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ErrorScreen();
  }
}

@TypedGoRoute<SplashRoute>(path: RoutePath.splash)
class SplashRoute extends GoRouteData {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashScreen();
  }
}

@TypedGoRoute<DrawingRoute>(path: RoutePath.drawing)
class DrawingRoute extends GoRouteData {
  const DrawingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DrawingScreen();
  }
}
