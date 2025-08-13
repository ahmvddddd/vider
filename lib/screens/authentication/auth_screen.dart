// import 'package:flutter/material.dart';
// import '../../controllers/auth/sign_in_controller.dart';
// import '../../utils/helpers/helper_function.dart';
// import 'sign_in.dart';
// import 'sign_up.dart';
// import '../../../nav_menu.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   PageController pageController = PageController();
//   bool showSignin = true;
//   bool _checkingLogin = true;

//   void toggleScreen() {
//     setState(() {
//       showSignin = !showSignin;
//       pageController.jumpToPage(showSignin ? 0 : 1);
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     final loggedIn = await LoginController.isUserStillLoggedIn();

//     if (loggedIn && mounted) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (_) => const NavigationMenu()),
//       );
//     } else {
//       setState(() => _checkingLogin = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dark = HelperFunction.isDarkMode(context);
//     if (_checkingLogin) {
//       return Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//             strokeWidth: 4.0,
//             backgroundColor: dark ? Colors.white : Colors.black,
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       body: PageView(
//         scrollDirection: Axis.horizontal,
//         physics: const NeverScrollableScrollPhysics(),
//         controller: pageController,
//         children: <Widget>[
//           SignInScreen(toggleScreen: toggleScreen),
//           SignupScreen(toggleScreen: toggleScreen),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/auth/sign_in_controller.dart';
import '../../utils/helpers/helper_function.dart';
import 'sign_in.dart';
import 'sign_up.dart';
import '../../../nav_menu.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController pageController = PageController();
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
    // Run login check after UI renders to avoid blocking
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLoginStatus());
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await LoginController.isUserStillLoggedIn();
    if (!mounted) return;

    if (loggedIn) {
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            strokeWidth: 4.0,
            backgroundColor: dark ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SignInScreen(toggleScreen: toggleScreen),
          SignupScreen(toggleScreen: toggleScreen),
        ],
      ),
    );
  }
}
