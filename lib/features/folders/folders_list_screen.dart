import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/common_widgets/glass_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/injection.dart';
import '../../data/models/folder_model.dart';
import '../../data/repositories/contact_repository.dart';
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
}
