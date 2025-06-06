import 'package:blockchain_university_voting_system/blockchain/smart_contract_service.dart';
import 'package:blockchain_university_voting_system/blockchain/wallet_connect_initializer.dart';
import 'package:blockchain_university_voting_system/blockchain/wallet_connect_service.dart';
import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/data/theme_color.dart';
import 'package:blockchain_university_voting_system/database/shared_preferences.dart';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/candidate_provider.dart';
import 'package:blockchain_university_voting_system/provider/notification_provider.dart';
import 'package:blockchain_university_voting_system/provider/student_provider.dart';
import 'package:blockchain_university_voting_system/provider/theme_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_management_provider.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/routes/app_routes.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  final malaysia = tz.getLocation('Asia/Kuala_Lumpur');
  final now = tz.TZDateTime.now(malaysia);
  print('Malaysia time: $now');

  await FlutterLocalization.instance.ensureInitialized();

  await FirebaseService.setupFirebase();
  await FirebaseService.initLocalNotifications();
  await FirebaseService.setupNotificationHandlers();
  await FirebaseService.initializeNotificationSettings();
  
  await dotenv.load(fileName: ".env");

  // 重置区块链服务，确保每次启动应用时服务是干净的
  WalletConnectService.reset();
  SmartContractService.reset();

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
          create: (_) {
            // 每次都重置并创建新实例
            WalletConnectService.reset();
            return WalletConnectService();
          },
        ),
        Provider<SmartContractService>(
          create: (_) {
            // 每次都重置并创建新实例
            SmartContractService.reset();
            return SmartContractService();
          },
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserManagementProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CandidateProvider(),
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
        MapLocale('en', 
          AppLocale.en,
          countryCode: 'US',
          fontFamily: 'Font EN',
        ),
        MapLocale('ms', 
          AppLocale.ms,
          countryCode: 'MS',
          fontFamily: 'Font MS',
        ),
        MapLocale('zh', 
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
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
                userProvider.setUser(snapshot.data!);
                userProvider.setInitialRoute('/${RouterPath.homepage.path}');
                
                // 加载用户的部门和投票资格状态
                getIsEligibleForVoting().then((isEligible) {
                  userProvider.setIsEligibleForVoting(isEligible);
                });
                
                getDepartment().then((department) {
                  userProvider.setDepartment(department);
                });
              }
            }
            return _buildApp(themeProvider, userProvider);
          },
        )
      : _buildApp(themeProvider, userProvider);
  }

  Widget _buildApp(ThemeProvider themeProvider, dynamic userProvider) {
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
        initialLocation: userProvider?.initialRoute ?? '/${RouterPath.loginpage.path}',
        routes: [
          ShellRoute(
            builder: (context, state, child) {
              return WalletConnectInitializer(
                child: child,
              );
            },
            routes: router(userProvider?.initialRoute ?? '/${RouterPath.loginpage.path}', rootNavigatorKey),
          ),
        ],
      ),
    );
  }
}
