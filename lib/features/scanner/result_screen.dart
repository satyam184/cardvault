import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/contact_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common_widgets/glass_card.dart';

class ResultScreen extends StatefulWidget {
  final BusinessContact contact;

  const ResultScreen({super.key, required this.contact});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingModel _model;

  @override
  void initState() {
    super.initState();
    _model = TextEditingModel(widget.contact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Details'),
        actions: [
          TextButton(
            onPressed: () {
              // Save contact and return
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 30),
            Text('Extracted Information', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),
            _buildForm(),
          ],
        ),
      ),
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
                  child: Image.file(File(widget.contact.frontImagePath!), height: 120, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 4),
                const Text('Front', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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
                  child: Image.file(File(widget.contact.backImagePath!), height: 120, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 4),
                const Text('Back', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildField(LucideIcons.user, 'Full Name', _model.name),
        _buildField(LucideIcons.briefcase, 'Company', _model.company),
        _buildField(LucideIcons.award, 'Job Title', _model.jobTitle),
        _buildField(LucideIcons.mail, 'Email Address', _model.email),
        _buildField(LucideIcons.phone, 'Phone Number', _model.phone),
        _buildField(LucideIcons.globe, 'Website', _model.website),
        _buildField(LucideIcons.mapPin, 'Address', _model.address),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildField(IconData icon, String label, TextEditingController controller) {
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
