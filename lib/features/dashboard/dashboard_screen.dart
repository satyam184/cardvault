import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/common_widgets/glass_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/injection.dart';
import '../../data/repositories/contact_repository.dart';
import '../folders/folder_detail_screen.dart';
import '../scanner/scanner_screen.dart';
import 'bloc/dashboard_bloc.dart';
import 'bloc/dashboard_event.dart';
import 'bloc/dashboard_state.dart';

import '../auth/bloc/auth_bloc.dart';

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
                    _buildAppBar(context, horizontalPadding),
                    _buildStats(context, horizontalPadding),
                    _buildFolderHeader(context, horizontalPadding),
                    _buildFolderGrid(context, horizontalPadding),
                  ],
                ),
              ),
            ),
            floatingActionButton: _buildFAB(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double horizontalPadding) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello,', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  'CardVault',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.logOut, color: Colors.white70),
                  onPressed: () {
                    context.read<AuthBloc>().add(LoggedOut());
                  },
                ),
                IconButton(
                  icon: const Icon(LucideIcons.bell, color: Colors.white70),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, double horizontalPadding) {
    return SliverToBoxAdapter(
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final total = state is DashboardLoaded ? state.totalCards : 0;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    total.toString(),
                    'Total Cards',
                    LucideIcons.creditCard,
                  ),
                  const VerticalDivider(
                    color: Colors.white10,
                    indent: 20,
                    endIndent: 20,
                  ),
                  _buildStatItem(
                    context,
                    'Today',
                    'Scan more',
                    LucideIcons.trendingUp,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).scaleXY(begin: 0.95),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderHeader(BuildContext context, double horizontalPadding) {
    return SliverToBoxAdapter(
      child: Padding(
        padding:
            EdgeInsets.fromLTRB(horizontalPadding, 30, horizontalPadding, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Folders', style: Theme.of(context).textTheme.titleLarge),
            Builder(
              builder: (innerContext) => IconButton(
                icon: const Icon(
                  LucideIcons.plusCircle,
                  color: AppColors.primary,
                ),
                onPressed: () => _showCreateFolderDialog(innerContext),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderGrid(BuildContext context, double horizontalPadding) {
    final size = MediaQuery.of(context).size;
    final crossAxisCount = size.width > 900 ? 4 : (size.width > 600 ? 3 : 2);

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is DashboardError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.alertCircle,
                      color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  const Text('Something went wrong',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        context.read<DashboardBloc>().add(LoadDashboard()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is DashboardLoaded) {
          if (state.folders.isEmpty) {
            return const SliverFillRemaining(
              child: Center(
                child: Text('No folders yet. Create one!',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            );
          }
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.1,
              ),
          delegate: SliverChildBuilderDelegate((context, index) {
                if (index == state.folders.length) {
                  // Show "See More" tile
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/folders'),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.arrowRight,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'See All',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  );
                }

                final folder = state.folders[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FolderDetailScreen(folder: folder),
                      ),
                    );
                  },
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.folder,
                          color: AppColors.primary,
                          size: 30,
                        ),
                        const Spacer(),
                        Text(
                          folder.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${folder.contactCount} Cards',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (index * 100).ms)
                      .slideY(begin: 0.1),
                );
              }, childCount: state.folders.length + (state.folders.length >= 3 ? 1 : 0)),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox());
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScannerScreen()),
        );
      },
      backgroundColor: AppColors.primary,
      label: const Text('Scan Card'),
      icon: const Icon(LucideIcons.scan),
    ).animate().scaleXY(delay: 500.ms, begin: 0, curve: Curves.elasticOut);
  }

  void _showCreateFolderDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('New Folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Folder Name',
                hintStyle: TextStyle(color: Colors.white38),
              ),
              autofocus: true,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: 'Description (Optional)',
                hintStyle: TextStyle(color: Colors.white38),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<DashboardBloc>().add(
                  CreateFolder(
                    nameController.text,
                    description: descController.text,
                  ),
                );
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
