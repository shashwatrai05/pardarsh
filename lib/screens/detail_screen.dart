import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectName;
  final String projectRegion;
  final String projectDetails;
  final String deadline;
  final String status;
  final String contractorEmail;
  final String description;

  const ProjectDetailsScreen({
    Key? key,
    required this.projectName,
    required this.projectRegion,
    required this.projectDetails,
    required this.deadline,
    required this.status,
    required this.contractorEmail,
    required this.description,
  }) : super(key: key);

  // Function to copy text to clipboard
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Project Details',
          style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.deepOrange),
        titleTextStyle: const TextStyle(color: Colors.deepOrange, fontSize: 22),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Name Section
              _buildSectionHeader(projectName, Colors.deepOrange),

              const SizedBox(height: 20),

              // Project Details Section (Region, Tender Details)
              _buildInfoSection('Region', projectRegion),
              _buildInfoSection('Tender Details', projectDetails),

              const SizedBox(height: 24),

              // Description Section
              _buildSectionHeader('Description', Colors.deepOrange),
              _buildTextSection(description),

              const SizedBox(height: 24),

              // Contractor Email Section with Copy Option
              _buildInfoSectionWithCopy('Contractor Email', contractorEmail, context),

              const SizedBox(height: 24),

              // Deadline Section
              _buildInfoSection('Deadline', deadline),

              const SizedBox(height: 24),

              // Status Section
              _buildInfoSection('Status', status),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Build a section header with a title and a custom color
  Widget _buildSectionHeader(String title, Color titleColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: titleColor,
        letterSpacing: 0.5,
      ),
    );
  }

  // Build a section with a label and a value (for details)
  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Build a section with a label and a value, but also includes a copy button for email
  Widget _buildInfoSectionWithCopy(
      String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.copy,
              color: Colors.deepOrange,
            ),
            onPressed: () => _copyToClipboard(context, value),
          ),
        ],
      ),
    );
  }

  // Build a text section (for Description or large texts)
  Widget _buildTextSection(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
