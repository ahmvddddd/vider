import 'package:flutter/material.dart';
import 'main.dart';
import 'repository/user/username_local_storage.dart';
import 'screens/authentication/auth_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'utils/helpers/helper_function.dart';
import 'utils/theme/theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();

    // Delay heavy work until after first frame to prevent freeze
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final username = await UsernameLocalStorage.getSavedUsername();
      if (!mounted) return;
      setState(() {
        _initialScreen = username != null
            ? const AuthScreen()
            : const OnboardingScreen();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: _initialScreen ??
          Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 6.0,
                backgroundColor: dark ? Colors.white : Colors.black,
              ),
            ),
          ),
    );
  }
}
