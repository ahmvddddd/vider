import 'package:flutter/material.dart';
import '../../controllers/auth/signin_controller.dart';
import '../../utils/helpers/helper_function.dart';
import 'signin.dart';
import 'signup.dart';
import '../../../nav_menu.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  PageController pageController = PageController();
  bool showSignin = true;
  bool _checkingLogin = true;

  void toggleScreen() {
    setState(() {
      showSignin = !showSignin;
      pageController.jumpToPage(showSignin ? 0 : 1);
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await LoginController.isUserStillLoggedIn();

    if (loggedIn && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NavigationMenu()),
      );
    } else {
      setState(() => _checkingLogin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    if (_checkingLogin) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // color
            strokeWidth: 4.0, // thickness of the line
            backgroundColor: dark ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    return Scaffold(
      body: PageView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: <Widget>[
          SigninScreen(toggleScreen: toggleScreen),
          SignupScreen(toggleScreen: toggleScreen),
        ],
      ),
    );
  }
}
