import 'dart:async';
import '../../data/models/contact_model.dart';
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
import '../dashboard/bloc/dashboard_bloc.dart';
import '../dashboard/bloc/dashboard_event.dart';

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
              _SearchBar(horizontalPadding: horizontalPadding),
              Expanded(
                child: _ContactList(
                  horizontalPadding: horizontalPadding,
                  folder: folder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final double horizontalPadding;

  const _SearchBar({required this.horizontalPadding});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<FolderBloc>().add(SearchContacts(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.horizontalPadding,
        vertical: 20,
      ),
      child: BlocBuilder<FolderBloc, FolderState>(
        builder: (context, state) {
          return GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            borderRadius: 15,
            child: TextField(
              onChanged: _onSearchChanged,
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
}

class _ContactList extends StatefulWidget {
  final double horizontalPadding;
  final ContactFolder folder;

  const _ContactList({required this.horizontalPadding, required this.folder});

  @override
  State<_ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<_ContactList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FolderBloc>().add(LoadMoreContacts(widget.folder.id));
    }
  }

  Future<void> _deleteContact(
    BuildContext context,
    BusinessContact contact,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Contact',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete ${contact.name}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleting ${contact.name}...')));
      await sl<ContactRepository>().deleteContact(contact.id);

      if (context.mounted) {
        // Also update Dashboard for global counts if applicable. Since Dashboard is globally provided, let's do it!
        context.read<DashboardBloc>().add(LoadDashboard());
        context.read<FolderBloc>().add(LoadFolderContacts(widget.folder.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact deleted successfully!'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FolderBloc, FolderState>(
      builder: (context, state) {
        if (state is FolderLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FolderError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.alertCircle,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.read<FolderBloc>().add(
                    LoadFolderContacts(widget.folder.id),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
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
          return RefreshIndicator(
            onRefresh: () async {
              context.read<FolderBloc>().add(
                LoadFolderContacts(widget.folder.id),
              );
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: widget.horizontalPadding,
                vertical: 10,
              ),
              itemCount: state.hasReachedMax
                  ? state.filteredContacts.length
                  : state.filteredContacts.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.filteredContacts.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final contact = state.filteredContacts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child:
                      GlassCard(
                            padding: const EdgeInsets.all(12),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.2,
                                ),
                                child: Text(
                                  contact.name.isNotEmpty
                                      ? contact.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                contact.name.isNotEmpty
                                    ? contact.name
                                    : 'No Name',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                (contact.company != null &&
                                        contact.company!.isNotEmpty)
                                    ? contact.company!
                                    : 'No Company',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.trash2,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _deleteContact(context, contact),
                                  ),
                                  const Icon(
                                    LucideIcons.chevronRight,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ContactEditScreen(contact: contact),
                                  ),
                                );

                                if (result == true && context.mounted) {
                                  context.read<FolderBloc>().add(
                                    LoadFolderContacts(widget.folder.id),
                                  );
                                }
                              },
                            ),
                          )
                          .animate()
                          .fadeIn(delay: (index % 10 * 50).ms)
                          .slideY(begin: 0.1),
                );
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
