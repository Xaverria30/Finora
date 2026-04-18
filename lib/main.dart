import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'config/theme/app_theme.dart';
import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'repositories/budget_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/saving_goal_repository.dart';
import 'repositories/transaction_repository.dart';
import 'services/api_service.dart';
import 'services/preferences_service.dart';
import 'services/service_locator.dart';
import 'services/firebase_messaging_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/budget_viewmodel.dart';
import 'viewmodels/category_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'viewmodels/saving_viewmodel.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/home/dashboard_screen.dart';
import 'views/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set default locale
  Intl.defaultLocale = 'id_ID';

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseMessagingService _firebaseMessagingService;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    _firebaseMessagingService = FirebaseMessagingService();

    // TODO: Replace with your actual API base URL dan user ID
    const apiBaseUrl = 'https://your-api.com'; // Replace dengan API URL
    const userId = 'user-id'; // Get dari auth context saat user login

    await _firebaseMessagingService.initialize(
      apiBaseUrl: apiBaseUrl,
      userId: userId,
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferencesService = PreferencesService(widget.prefs);
    final apiService = ServiceLocator.getApiService(
      preferencesService: preferencesService,
    );

    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (context) => apiService),
        Provider<PreferencesService>(create: (context) => preferencesService),
        Provider<FirebaseMessagingService>(
          create: (context) => _firebaseMessagingService,
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepository(apiService: apiService),
        ),
        Provider<TransactionRepository>(
          create: (context) => TransactionRepository(apiService: apiService),
        ),
        Provider<CategoryRepository>(
          create: (context) => CategoryRepository(apiService: apiService),
        ),
        Provider<SavingGoalRepository>(
          create: (context) => SavingGoalRepository(apiService: apiService),
        ),
        Provider<BudgetRepository>(
          create: (context) => BudgetRepository(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AuthViewModel(authRepository: context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => TransactionViewModel(
            transactionRepository: context.read<TransactionRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryViewModel(
            categoryRepository: context.read<CategoryRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SavingViewModel(
            savingGoalRepository: context.read<SavingGoalRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BudgetViewModel(
            budgetRepository: context.read<BudgetRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DashboardViewModel(
            transactionRepository: context.read<TransactionRepository>(),
          ),
        ),
        ChangeNotifierProvider(create: (context) => NotificationViewModel()),
      ],
      child: MaterialApp(
        title: 'Finora',
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
        routes: {'/home': (context) => const MainNavigationScreen()},
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
