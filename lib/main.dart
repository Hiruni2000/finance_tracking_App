import 'package:finance_app/controllers/authController.dart';
import 'package:finance_app/controllers/budgetController.dart';
import 'package:finance_app/controllers/transactionController.dart';
import 'package:finance_app/firebase_options.dart';
import 'package:finance_app/views/transactionPage.dart';
import 'package:finance_app/views/transactionHistoryPage.dart';
import 'package:finance_app/views/budgetPlanningPage.dart';
import 'package:finance_app/views/dashbord.dart';
import 'package:finance_app/views/loginPage.dart';
import 'package:finance_app/views/registerPage.dart';
import 'package:finance_app/views/ReportsPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide controllers and providers
        ChangeNotifierProvider(create: (_) => AuthController()),
        Provider(create: (_) => TransactionController()),
        Provider(create: (_) => BudgetController()),
      ],
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute:
                authController.isLoading
                    ? '/'
                    : authController.isAuthenticated
                    ? '/dashboard'
                    : '/',
            routes: {
              '/': (context) => const LoginView(),
              '/register': (context) => const RegisterView(),
              '/dashboard': (context) => const DashboardView(),
              '/addTransaction': (context) => const AddTransactionView(),
              '/transactionHistory':
                  (context) => const TransactionHistoryView(),
              '/budgetPlanner': (context) => const BudgetPlanningView(),
              '/reports': (context) => const ReportsInsightsView(),
            },
          );
        },
      ),
    );
  }
}
