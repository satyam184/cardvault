import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../contacts/contact_edit_screen.dart';

import '../../core/common_widgets/glass_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/excel_service.dart';
import '../../core/utils/injection.dart';
import '../../data/models/folder_model.dart';
import '../../data/repositories/contact_repository.dart';
import 'bloc/folder_bloc.dart';
import 'bloc/folder_event.dart';
import 'bloc/folder_state.dart';

class FolderDetailScreen extends StatelessWidget {
  final ContactFolder folder;

  const FolderDetailScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width > 600 ? size.width * 0.1 : 20.0;

    return BlocProvider(
      create: (context) =>
          FolderBloc(repository: sl<ContactRepository>())
            ..add(LoadFolderContacts(folder.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(folder.name),
          actions: [
            BlocBuilder<FolderBloc, FolderState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(LucideIcons.download),
                  onPressed: state is FolderLoaded
                      ? () => sl<ExcelService>().exportContacts(
                          state.contacts,
                          folderName: folder.name,
                        )
                      : null,
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomRight,
              radius: 1.5,
              colors: [
                AppColors.secondary.withOpacity(0.05),
                AppColors.background,
              ],
            ),
          ),
          child: Column(
            children: [
              _buildSearchBar(context, horizontalPadding),
              Expanded(child: _buildContactList(context, horizontalPadding)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
      child: BlocBuilder<FolderBloc, FolderState>(
        builder: (context, state) {
          return GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            borderRadius: 15,
            child: TextField(
              onChanged: (value) =>
                  context.read<FolderBloc>().add(SearchContacts(value)),
              decoration: const InputDecoration(
                icon: Icon(
                  LucideIcons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                hintText: 'Search contacts...',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ).animate().fadeIn().slideX();
        },
      ),
    );
  }

  Widget _buildContactList(BuildContext context, double horizontalPadding) {
    return BlocBuilder<FolderBloc, FolderState>(
      builder: (context, state) {
        if (state is FolderLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FolderLoaded) {
          if (state.filteredContacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.userX,
                    size: 60,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No contacts found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
            itemCount: state.filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = state.filteredContacts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        contact.name[0],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(contact.company ?? 'No Company'),
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      color: AppColors.textMuted,
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactEditScreen(contact: contact),
                        ),
                      );
                      
                      if (result == true && context.mounted) {
                        context.read<FolderBloc>().add(LoadFolderContacts(folder.id));
                      }
                    },
                  ),
                ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
