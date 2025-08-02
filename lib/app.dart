import 'package:flutter/material.dart';
// import 'main.dart';
// import 'screens/authentication/signin.dart';
// import 'screens/authentication/signup.dart';
import 'nav_menu.dart';
import 'utils/theme/theme.dart';

class App extends StatefulWidget {
   const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  PageController pageController = PageController();
  bool showSignin = true;

  void toggleScreen() {
    setState(() {
      showSignin = !showSignin;
      pageController.jumpToPage(showSignin ? 0 : 1);
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          // navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home:   NavigationMenu(),
      // Scaffold(
      //   body: PageView(
      //     scrollDirection: Axis.horizontal,
      //     physics: const NeverScrollableScrollPhysics(),
      //     controller: pageController,
      //     children: <Widget>[
      //       SigninScreen(toggleScreen: toggleScreen),
      //       SignupScreen(toggleScreen: toggleScreen),
      //     ],
      //   ),
      // ),
    );
  }
}
