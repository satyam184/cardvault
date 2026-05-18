import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';

class FolderHeader extends StatelessWidget {
  final double horizontalPadding;

  const FolderHeader({super.key, required this.horizontalPadding});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          30,
          horizontalPadding,
          10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Folders', style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              icon: const Icon(
                LucideIcons.plusCircle,
                color: AppColors.primary,
              ),
              onPressed: () => _showCreateFolderDialog(context),
            ),
          ],
        ),
      ),
    );
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
            // const SizedBox(height: 15),
            // TextField(
            //   controller: descController,
            //   decoration: const InputDecoration(
            //     hintText: 'Description (Optional)',
            //     hintStyle: TextStyle(color: Colors.white38),
            //   ),
            //   style: const TextStyle(color: Colors.white),
            // ),
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
                  CreateFolder(nameController.text, description: 'description'),
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
