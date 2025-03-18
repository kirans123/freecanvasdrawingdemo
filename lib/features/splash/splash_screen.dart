import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_path.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      context.pushReplacement(RoutePath.drawing);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      color: Colors.red,
      height: 400,
      width: 400,
    ));
  }
}
