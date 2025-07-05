import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'models/user_model.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تهيئة خدمة الثيم
  final themeService = ThemeService();
  await themeService.loadTheme();

  // إعداد شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  
  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'DADA GYM',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            localizationsDelegates: const [
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale("ar", "DZ"),
              Locale("en", "US"),
            ],
            home: const SplashScreenWrapper(),
          );
        },
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final userModel = await authService.getUserData(user.uid);
    
    if (userModel == null) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    if (!userModel.isActivated) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    if (!mounted) return;
    
    if (userModel.role == UserRole.admin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AdminDashboard(admin: userModel)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(user: userModel)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}