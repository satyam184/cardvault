import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/folder_model.dart';
import '../../data/repositories/contact_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common_widgets/glass_card.dart';
import '../../core/utils/injection.dart';
import '../dashboard/bloc/dashboard_bloc.dart';
import '../dashboard/bloc/dashboard_event.dart';

class ResultScreen extends StatefulWidget {
  final BusinessContact contact;

  const ResultScreen({super.key, required this.contact});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingModel _model;
  final _selectedFolderId = ValueNotifier<String?>(null);
  final _folders = ValueNotifier<List<ContactFolder>>([]);
  final _isSaving = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _selectedFolderId.dispose();
    _folders.dispose();
    _isSaving.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _model = TextEditingModel(widget.contact);
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    try {
      final folders = await sl<ContactRepository>().getFoldersList();
      if (mounted) {
        _folders.value = folders;
        if (folders.isNotEmpty) {
          _selectedFolderId.value = folders.first.id;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading folders: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width > 600 ? size.width * 0.1 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Details'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isSaving,
            builder: (context, isSaving, _) {
              return TextButton(
                onPressed: isSaving ? null : _saveContact,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 30),
            Text(
              'Save to Folder',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _buildFolderDropdown(),
            const SizedBox(height: 30),
            Text(
              'Extracted Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 15),
            _buildForm(size.width > 600),
          ],
        ),
      ),
    );
  }

  Future<void> _saveContact() async {
    if (_selectedFolderId.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or create a folder first')),
      );
      return;
    }

    _isSaving.value = true;

    final newContact = BusinessContact(
      id: widget.contact.id,
      name: _model.name.text,
      company: _model.company.text,
      jobTitle: _model.jobTitle.text,
      email: _model.email.text,
      phone: _model.phone.text,
      website: _model.website.text,
      address: _model.address.text,
      folderId: _selectedFolderId.value!,
      frontImagePath: widget.contact.frontImagePath,
      backImagePath: widget.contact.backImagePath,
      createdAt: widget.contact.createdAt,
    );

    try {
      await sl<ContactRepository>().createContact(
        newContact,
        _selectedFolderId.value!,
      );

      if (mounted) {
        context.read<DashboardBloc>().add(LoadDashboard());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card saved successfully!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        _isSaving.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save card: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildFolderDropdown() {
    return ValueListenableBuilder<String?>(
      valueListenable: _selectedFolderId,
      builder: (context, selectedFolderId, _) {
        return ValueListenableBuilder<List<ContactFolder>>(
          valueListenable: _folders,
          builder: (context, folders, _) {
            return GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: 15,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFolderId,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  items: folders
                      .map(
                        (f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(
                            f.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => _selectedFolderId.value = val,
                  hint: const Text(
                    'Select Folder',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImagePreview() {
    return Row(
      children: [
        if (widget.contact.frontImagePath != null)
          Expanded(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.contact.frontImagePath!),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Front',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        if (widget.contact.backImagePath != null) ...[
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.contact.backImagePath!),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildForm(bool isWide) {
    final fields = [
      _buildField(Icons.person_outline, 'Full Name', _model.name),
      _buildField(Icons.work_outline, 'Company', _model.company),
      _buildField(Icons.emoji_events_outlined, 'Job Title', _model.jobTitle),
      _buildField(Icons.email_outlined, 'Email Address', _model.email),
      _buildField(Icons.phone, 'Phone Number', _model.phone),
      _buildField(Icons.public, 'Website', _model.website),
      _buildField(Icons.location_on_outlined, 'Address', _model.address),
    ];

    if (!isWide) {
      return Column(children: fields).animate().fadeIn(delay: 200.ms);
    }

    return Wrap(
      spacing: 20,
      runSpacing: 0,
      children: fields
          .map(
            (f) => SizedBox(
              width: (MediaQuery.of(context).size.width * 0.8 - 20) / 2,
              child: f,
            ),
          )
          .toList(),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildField(
    IconData icon,
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            icon: Icon(icon, color: AppColors.primary, size: 20),
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class TextEditingModel {
  final TextEditingController name;
  final TextEditingController company;
  final TextEditingController jobTitle;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController website;
  final TextEditingController address;

  TextEditingModel(BusinessContact contact)
    : name = TextEditingController(text: contact.name),
      company = TextEditingController(text: contact.company),
      jobTitle = TextEditingController(text: contact.jobTitle),
      email = TextEditingController(text: contact.email),
      phone = TextEditingController(text: contact.phone),
      website = TextEditingController(text: contact.website),
      address = TextEditingController(text: contact.address);
}
