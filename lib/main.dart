import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/injection.dart' as di;
import 'core/utils/injection.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/auth/auth_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/folders/folders_list_screen.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/dashboard/bloc/dashboard_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Dependency Injection
  await di.init();
  
  runApp(const CardVaultApp());
}

class CardVaultApp extends StatelessWidget {
  const CardVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AppStarted()),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => sl<DashboardBloc>()..add(LoadDashboard()),
        ),
      ],
      child: MaterialApp(
        title: 'CardVault',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/auth': (context) => const AuthScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/folders': (context) => const FoldersListScreen(),
        },
      ),
    );
  }
}

// Placeholder removed
