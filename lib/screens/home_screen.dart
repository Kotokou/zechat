import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:zechat/configs/constants/app_colors.dart';
import 'package:zechat/models/popup_choices.dart';
import 'package:zechat/providers/auth_provider.dart';
import 'package:zechat/screens/login_screen.dart';
import 'package:zechat/screens/setting_screen.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController scrollController = ScrollController();

  late String currentUserId;
  late AuthProvider authProvider;

  // late HomeProvider homeProvider;

  bool isLoading = false;
  int limit = 20;
  int limitIncrement = 20;
  String textSearch = "";

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    // homeProvider = context.read<HomeProvider>();

    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return const LoginScreen();
      }), (route) => false);
    }

    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        limit += limitIncrement;
      });
    }
  }

  Future handleSignOut() async {
    authProvider.handleSignOut();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const LoginScreen();
    }));
  }

  void onItemMenuPress(PopupChoices choice) {
    print("press");
    if (choice.title == "Sign out") {
      handleSignOut();
    } else {
      print("settings");
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return  SettingScreen();
      }));
    }
  }

  Widget buildPopupMenu() {
    return PopupMenuButton<PopupChoices>(
      icon: const Icon(Icons.more_vert_outlined, color: Colors.grey),
      onSelected: (choice) {
        onItemMenuPress(choice);
      },
      itemBuilder: (context) {
        return choices.map((PopupChoices choice) {
          return PopupMenuItem<PopupChoices>(
            value: choice,
            child: ListTile(
              leading: Icon(
                choice.icon,
                color: AppColors.primaryColor,
              ),
              title: Text(
                choice.title,
                style: const TextStyle(color: AppColors.primaryColor),
              ),
            ),
          );
        }).toList();
      },
    );
  }

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: "Settings", icon: Icons.settings_outlined),
    PopupChoices(title: "Sign out", icon: Icons.exit_to_app_outlined)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        leading: IconButton(
          icon: Switch(
            value: isWhite,
            onChanged: (value) {
              setState(() {
                isWhite = value;
                debugPrint("$isWhite");
              });
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.grey,
            inactiveThumbColor: Colors.black45,
            inactiveTrackColor: Colors.grey,
          ),
          onPressed: () {},
        ),
        actions: <Widget>[buildPopupMenu()],
      ),
    );
  }
}
