import 'package:blockchain_university_voting_system/blockchain/smart_contract_service.dart';
import 'package:blockchain_university_voting_system/blockchain/wallet_connect_initializer.dart';
import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/data/theme_color.dart';
import 'package:blockchain_university_voting_system/database/shared_preferences.dart';
import 'package:blockchain_university_voting_system/firebase_options.dart';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/notification_provider.dart';
import 'package:blockchain_university_voting_system/provider/student_provider.dart';
import 'package:blockchain_university_voting_system/provider/theme_provider.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/routes/app_routes.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blockchain_university_voting_system/blockchain/wallet_connect_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterLocalization.instance.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  // Determine the initial route
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isLoggedIn = prefs.getBool('isLoggedIn');
  Future<User?>? user;
  if (isLoggedIn != null && isLoggedIn) {
    user = loadUserLoginStatus();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => VotingEventProvider()
        ),
        ChangeNotifierProvider(
          create: (_) => StudentProvider()
        ),
        Provider<WalletConnectService>(
          create: (_) => WalletConnectService(),
        ),
        Provider<SmartContractService>(
          create: (_) => SmartContractService(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: MainApp(user: user),
    ),
  );
}

class MainApp extends StatefulWidget {
  final Future<User?>? user;

  const MainApp({
    super.key,
    this.user,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();
    _localization.init(
      mapLocales: [
        const MapLocale('en', 
          AppLocale.en,
          countryCode: 'US',
          fontFamily: 'Font EN',
        ),
        const MapLocale('ms', 
          AppLocale.ms,
          countryCode: 'MS',
          fontFamily: 'Font MS',
        ),
        const MapLocale('zh', 
          AppLocale.zh,
          countryCode: 'ZH',
          fontFamily: 'Font ZH',
        ),
      ], 
      initLanguageCode: 'zh',
    );
    _localization.onTranslatedLanguage = _onTranslatedLanguage;
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userViewModel = Provider.of<UserProvider>(context, listen: false);
    
    return widget.user != null
      ? FutureBuilder(
          future: widget.user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error loading user data');
            } else {
              if (snapshot.data != null) {
                userViewModel.setUser(snapshot.data!);
                userViewModel.setInitialRoute('/${RouterPath.homepage.path}');
              }
            }
            return _buildApp(themeProvider, userViewModel);
          },
        )
      : _buildApp(themeProvider, userViewModel);
  }

  Widget _buildApp(ThemeProvider themeProvider, dynamic userViewModel) {
    return MaterialApp.router(
      supportedLocales: _localization.supportedLocales,
      localizationsDelegates: [
        ..._localization.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      title: 'Blockchain University Voting System',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      routerConfig: GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: userViewModel?.initialRoute ?? '/${RouterPath.loginpage.path}',
        routes: [
          ShellRoute(
            builder: (context, state, child) {
              return WalletConnectInitializer(
                child: child,
              );
            },
            routes: router(userViewModel?.initialRoute ?? '/${RouterPath.loginpage.path}', rootNavigatorKey),
          ),
        ],
      ),
    );
  }
}
