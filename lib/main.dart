import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/injection.dart' as di;
import 'core/utils/injection.dart';
import 'core/common_widgets/connectivity_wrapper.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/auth/auth_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/folders/folders_list_screen.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/dashboard/bloc/dashboard_event.dart';

void main() async {
  Sentry.init(
    (options) {
      options.dsn =
          'https://ed3de42023614381ba0e53f9770f1de0@o4511405972783104.ingest.us.sentry.io/4511405974028288';

      options.tracesSampleRate = 1.0;
    },
    appRunner: () {
      runZonedGuarded(
        () async {
          WidgetsFlutterBinding.ensureInitialized();
          await dotenv.load(fileName: ".env");
          await di.init();

          FlutterError.onError = (FlutterErrorDetails details) async {
            await Sentry.captureException(
              details.exception,
              stackTrace: details.stack,
            );
          };

          PlatformDispatcher.instance.onError = (error, stack) {
            Sentry.captureException(error, stackTrace: stack);
            return true;
          };

          runApp(const CardVaultApp());
        },
        (error, stack) async {
          await Sentry.captureException(error, stackTrace: stack);
        },
      );
    },
  );
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
        builder: (context, child) {
          return ConnectivityWrapper(child: child!);
        },
      ),
    );
  }
}
