import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final DocumentSnapshot project;

  const ProjectDetailsScreen({required this.project, super.key});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late TextEditingController tenderDetailsController;
  late TextEditingController materialCostController;
  late TextEditingController laborCostController;
  late TextEditingController constructionCostController;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> projectData = widget.project.data() as Map<String, dynamic>? ?? {};
    tenderDetailsController = TextEditingController(text: projectData['tenderDetails'] ?? '');
    materialCostController = TextEditingController(text: (projectData['materialCost'] ?? '0').toString());
    laborCostController = TextEditingController(text: (projectData['laborCost'] ?? '0').toString());
    constructionCostController = TextEditingController(text: (projectData['constructionCost'] ?? '0').toString());
  }

  Future<void> _updateTenderDetails() async {
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.project.id)
          .update({
        'tenderDetails': tenderDetailsController.text.trim(),
        'materialCost': int.tryParse(materialCostController.text.trim()) ?? 0,
        'laborCost': int.tryParse(laborCostController.text.trim()) ?? 0,
        'constructionCost': int.tryParse(constructionCostController.text.trim()) ?? 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tender details updated successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating tender: ${e.toString()}')));
    }
  }

  Future<void> _refreshPage() async {
    try {
      final updatedProject = await FirebaseFirestore.instance.collection('projects').doc(widget.project.id).get();

      if (updatedProject.exists) {
        final projectData = updatedProject.data() as Map<String, dynamic>? ?? {};
        setState(() {
          tenderDetailsController.text = projectData['tenderDetails'] ?? '';
          materialCostController.text = (projectData['materialCost'] ?? '0').toString();
          laborCostController.text = (projectData['laborCost'] ?? '0').toString();
          constructionCostController.text = (projectData['constructionCost'] ?? '0').toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Page refreshed successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project data not found!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error refreshing page: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],  // Lighter background color for better contrast
      appBar: AppBar(
        title: const Text('Project Details'),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.blue),
        titleTextStyle: const TextStyle(color: Colors.blue, fontSize: 18),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Name
                Text(
                  widget.project['name'] ?? 'Unnamed Project',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // Project Region
                Text(
                  'Region: ${widget.project['region'] ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                // Description Card
                Card(
                  color: Colors.white60,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.project['description'] ?? 'No description available.',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tender Details Field
                _buildTextField(tenderDetailsController, 'Tender Details', isMultiline: true),
                const SizedBox(height: 16),
                // Cost Fields
                _buildTextField(materialCostController, 'Material Cost', inputType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField(laborCostController, 'Labor Cost', inputType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField(constructionCostController, 'Construction Cost', inputType: TextInputType.number),
                const SizedBox(height: 24),
                // Update Button
                Center(
                  child: ElevatedButton(
                    onPressed: _updateTenderDetails,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,  // Vibrant blue button
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Update Tender Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TextField Helper Widget
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType inputType = TextInputType.text, bool isMultiline = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blue),
        filled: true,
        fillColor: Colors.blueGrey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.black),
      keyboardType: inputType,
      maxLines: isMultiline ? 3 : 1,
    );
  }
}
