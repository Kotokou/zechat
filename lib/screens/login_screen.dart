import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:zechat/configs/widgets/loading_view.dart';
import 'package:zechat/providers/auth_provider.dart';
import 'package:zechat/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case Status.authentificateError:
        Fluttertoast.showToast(msg: "Connexion échouée");
        break;
      case Status.authentificateCanceled:
        Fluttertoast.showToast(msg: "Connexion annulée");
        break;
      case Status.authentificated:
        Fluttertoast.showToast(msg: "Connexion réussie");
        break;
      default:
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SvgPicture.asset(
                "images/back.svg",
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () async {
                  bool isSucess = await authProvider.handleSignin();
                  if (isSucess) {
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  }
                },
                child: Image.asset(
                  "images/google-signin-button.png",
                  width: 250,
                  height: 80,
                ),
              ),
            ),
            SizedBox(
              height: 30,
              width: 30,
              child: authProvider.status == Status.authentificating
                  ? const LoadingView()
                  : const SizedBox.shrink(),
            )
          ],
        ),
      ),
    );
  }
}
