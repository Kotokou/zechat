import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:zechat/configs/constants/app_colors.dart';
import 'package:zechat/providers/auth_provider.dart';
import 'package:zechat/screens/home_screen.dart';
import 'package:zechat/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 5),
      () {
        checkSignIn();
      },
    );
  }

  void checkSignIn() async {
    AuthProvider authProvider = context.read<AuthProvider>();

    bool isLoggedIn = await authProvider.isLoggedIn();
    if (isLoggedIn) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              "images/splash.svg",
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
            const Text(
              "ZeChat, Texto entre amis!!!",
              style: TextStyle(
                color: AppColors.themeColor,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 20,
              height: 20,
              color: Colors.transparent,
              child:
                  const CircularProgressIndicator(color: AppColors.themeColor),
            )
          ],
        ),
      ),
    );
  }
}
