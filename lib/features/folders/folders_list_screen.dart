import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/common_widgets/glass_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/injection.dart';
import '../../data/models/folder_model.dart';
import '../../data/repositories/contact_repository.dart';
import '../dashboard/bloc/dashboard_bloc.dart';
import '../dashboard/bloc/dashboard_event.dart';
import 'folder_detail_screen.dart';

class FoldersListScreen extends StatefulWidget {
  const FoldersListScreen({super.key});

  @override
  State<FoldersListScreen> createState() => _FoldersListScreenState();
}

class _FoldersListScreenState extends State<FoldersListScreen> {
  final List<ContactFolder> _folders = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMoreFolders();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreFolders();
      }
    });
  }

  Future<void> _loadMoreFolders() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newFolders = await sl<ContactRepository>().getFolders(
        page: _currentPage,
        limit: 15,
      );

      setState(() {
        _isLoading = false;
        if (newFolders.isEmpty) {
          _hasMore = false;
        } else {
          _folders.addAll(newFolders);
          _currentPage++;
          if (newFolders.length < 15) {
            _hasMore = false;
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Folders'),
      ),
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
        child: _folders.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _folders.isEmpty
                ? const Center(child: Text('No folders found'))
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _folders.clear();
                        _currentPage = 1;
                        _hasMore = true;
                      });
                      await _loadMoreFolders();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _folders.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _folders.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final folder = _folders[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GestureDetector(
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
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.folder,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          folder.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        if (folder.description != null &&
                                            folder.description!.isNotEmpty)
                                          Text(
                                            folder.description!,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${folder.contactCount}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const Text(
                                        'Cards',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(LucideIcons.moreVertical, color: Colors.white70),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditFolderDialog(context, folder);
                                      } else if (value == 'delete') {
                                        _showDeleteFolderDialog(context, folder);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: (index % 10 * 50).ms).slideX(),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  void _showEditFolderDialog(BuildContext context, dynamic folder) {
    final nameController = TextEditingController(text: folder.name);
    final descController = TextEditingController(text: folder.description);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Folder'),
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
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(dialogContext); // Close dialog immediately
                try {
                  await sl<ContactRepository>().updateFolder(
                    folder.id,
                    nameController.text,
                    description: descController.text,
                  );
                  if (context.mounted) {
                    context.read<DashboardBloc>().add(LoadDashboard());
                  }
                  setState(() {
                    _folders.clear();
                    _currentPage = 1;
                    _hasMore = true;
                  });
                  await _loadMoreFolders();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update: $e')),
                    );
                  }
                }
              } else {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFolderDialog(BuildContext context, dynamic folder) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Folder'),
        content: Text('Are you sure you want to delete "${folder.name}"?\nThis action cannot be undone.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog immediately
              try {
                await sl<ContactRepository>().deleteFolder(folder.id);
                if (context.mounted) {
                  context.read<DashboardBloc>().add(LoadDashboard());
                }
                setState(() {
                  _folders.clear();
                  _currentPage = 1;
                  _hasMore = true;
                });
                await _loadMoreFolders();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
