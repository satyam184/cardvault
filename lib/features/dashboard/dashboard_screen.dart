import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/injection.dart';
import '../../data/repositories/contact_repository.dart';
import '../auth/bloc/auth_bloc.dart';
import 'bloc/dashboard_bloc.dart';
import 'bloc/dashboard_event.dart';
import 'bloc/dashboard_state.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_stats.dart';
import 'widgets/folder_header.dart';
import 'widgets/folder_grid.dart';
import 'widgets/dashboard_fab.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width > 600 ? size.width * 0.1 : 20.0;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      },
      child: BlocProvider(
        create: (context) =>
            DashboardBloc(repository: sl<ContactRepository>())
              ..add(LoadDashboard()),
        child: BlocListener<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state is DashboardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.background.withOpacity(0.8),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    DashboardAppBar(horizontalPadding: horizontalPadding),
                    DashboardStats(horizontalPadding: horizontalPadding),
                    FolderHeader(horizontalPadding: horizontalPadding),
                    FolderGrid(horizontalPadding: horizontalPadding),
                  ],
                ),
              ),
            ),
            floatingActionButton: const DashboardFAB(),
          ),
        ),
      ),
    );
  }
}
