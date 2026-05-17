import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/common_widgets/glass_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/injection.dart';
import '../../data/models/contact_model.dart';
import '../../data/repositories/contact_repository.dart';

class ContactEditScreen extends StatefulWidget {
  final BusinessContact contact;

  const ContactEditScreen({super.key, required this.contact});

  @override
  State<ContactEditScreen> createState() => _ContactEditScreenState();
}

class _ContactEditScreenState extends State<ContactEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'name': TextEditingController(text: widget.contact.name),
      'company': TextEditingController(text: widget.contact.company),
      'jobTitle': TextEditingController(text: widget.contact.jobTitle),
      'email': TextEditingController(text: widget.contact.email),
      'phone': TextEditingController(text: widget.contact.phone),
      'website': TextEditingController(text: widget.contact.website),
      'address': TextEditingController(text: widget.contact.address),
      'notes': TextEditingController(text: widget.contact.notes),
    };
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final updateData = {
        'folderId': widget.contact.folderId,
        'name': _controllers['name']!.text,
        'company': _controllers['company']!.text,
        'jobTitle': _controllers['jobTitle']!.text,
        'email': _controllers['email']!.text,
        'phone': _controllers['phone']!.text,
        'website': _controllers['website']!.text,
        'address': _controllers['address']!.text,
        'notes': _controllers['notes']!.text,
        'linkedin': widget.contact.linkedin ?? '',
      };

      try {
        await sl<ContactRepository>().updateContact(widget.contact.id, updateData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card updated successfully!'),
              backgroundColor: AppColors.secondary,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update card: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Card'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(LucideIcons.save, color: AppColors.primary),
              onPressed: _saveContact,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomRight,
            radius: 1.5,
            colors: [
              AppColors.secondary.withValues(alpha: 0.05),
              AppColors.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? size.width * 0.1 : 20,
            vertical: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSectionHeader('Basic Information', LucideIcons.user),
                const SizedBox(height: 15),
                _buildResponsiveGrid([
                  _buildTextField(
                    _controllers['name']!,
                    'Full Name',
                    LucideIcons.user,
                    required: true,
                  ),
                  _buildTextField(
                    _controllers['company']!,
                    'Company',
                    LucideIcons.building,
                  ),
                  _buildTextField(
                    _controllers['jobTitle']!,
                    'Job Title',
                    LucideIcons.briefcase,
                  ),
                ], isTablet),

                const SizedBox(height: 30),
                _buildSectionHeader('Card Details', LucideIcons.phone),
                const SizedBox(height: 15),
                _buildResponsiveGrid([
                  _buildTextField(
                    _controllers['email']!,
                    'Email',
                    LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    _controllers['phone']!,
                    'Phone',
                    LucideIcons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    _controllers['website']!,
                    'Website',
                    LucideIcons.globe,
                  ),
                ], isTablet),

                const SizedBox(height: 30),
                _buildSectionHeader('Additional Info', LucideIcons.mapPin),
                const SizedBox(height: 15),
                _buildTextField(
                  _controllers['address']!,
                  'Address',
                  LucideIcons.mapPin,
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  _controllers['notes']!,
                  'Notes',
                  LucideIcons.fileText,
                  maxLines: 4,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildResponsiveGrid(List<Widget> children, bool isTablet) {
    if (!isTablet) {
      return Column(
        children: children
            .map(
              (w) =>
                  Padding(padding: const EdgeInsets.only(bottom: 15), child: w),
            )
            .toList(),
      );
    }

    // For tablet, we can use a Wrap or a Grid
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: children
          .map(
            (w) => SizedBox(
              width: (MediaQuery.of(context).size.width * 0.8 - 20) / 2,
              child: w,
            ),
          )
          .toList(),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 15,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          icon: Icon(icon, color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
          floatingLabelStyle: const TextStyle(color: AppColors.primary),
        ),
        validator: required
            ? (value) => (value == null || value.isEmpty) ? 'Required' : null
            : null,
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}
