import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class GovernmentPortal extends StatefulWidget {
  const GovernmentPortal({super.key});

  @override
  State<GovernmentPortal> createState() => _GovernmentPortalState();
}

class _GovernmentPortalState extends State<GovernmentPortal> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tenderDetailsController =
      TextEditingController();
  final TextEditingController _contractorIdController = TextEditingController();

  String? _selectedRegion;
  DateTime? _selectedDate;
  bool _isGovernment = false;
  bool _isLoading = true;

  final List<String> regions = ['Ghaziabad', 'Noida'];

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // Check if the user has the 'Government Official' role
  Future<void> _checkUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        String role = userDoc['role'];
        if (role == 'Government Official') {
          setState(() {
            _isGovernment = true;
          });
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/signin');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
    }
  }

  // Method to add a new project and assign a contractor
// Method to add a new project and assign a contractor
Future<void> _addProject() async {
  if (_selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid deadline')));
    return;
  }

  // If contractor ID is provided, proceed with assigning contractor
  String contractorId = _contractorIdController.text.trim();

  try {
    // Add the project to the Firestore projects collection
    DocumentReference projectRef = await _firestore.collection('projects').add({
      'name': _projectNameController.text.trim(),
      'region': _selectedRegion,
      'description': _descriptionController.text.trim(),
      'tenderDetails': _tenderDetailsController.text.trim(),
      'deadline': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'contractorId': contractorId.isNotEmpty ? contractorId : null,  // Assign contractor if provided
      'status': 'Open',
      'createdBy': _auth.currentUser!.uid,
      'createdAt': Timestamp.now(),
    });

    // If contractor ID is provided, update the contractor's document
    if (contractorId.isNotEmpty) {
      DocumentReference contractorRef =
          _firestore.collection('contractors').doc(contractorId);

      // Check if contractor document exists
      DocumentSnapshot contractorDoc = await contractorRef.get();

      if (!contractorDoc.exists) {
        // If contractor document does not exist, create it
        await contractorRef.set({
          'name': contractorId,  // Or any other relevant data
          'assignedProjects': [projectRef.id],
        });
      } else {
        // If contractor document exists, update the assigned projects field
        await contractorRef.update({
          'assignedProjects': FieldValue.arrayUnion([projectRef.id]),
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project added successfully!')));

    // Clear fields after submission
    _projectNameController.clear();
    _descriptionController.clear();
    _tenderDetailsController.clear();
    _contractorIdController.clear();
    _selectedRegion = null;
    _selectedDate = null;

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')));
  }
}


  Future<void> _selectDeadline(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2101);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isGovernment) {
      return Scaffold(
        body: Center(
          child: Text(
            'Access Denied: You are not authorized to access this portal.',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Government Portal'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              _buildTextField(_projectNameController, 'Project Name'),
              const SizedBox(height: 16),
              _buildRegionDropdown(),
              const SizedBox(height: 16),
              _buildTextField(
                _descriptionController,
                'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _tenderDetailsController,
                'Tender Details',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildDeadlineField(),
              const SizedBox(height: 16),
              _buildTextField(
                _contractorIdController,
                'Contractor ID (optional)',
                hintText: 'Leave blank if no contractor assigned',
                maxLines: 1,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _addProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add Project',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextField Widget
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.black),
        hintStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.email, color: Colors.grey),
      ),
      maxLines: maxLines,
    );
  }

  // Region Dropdown
  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRegion,
      hint: const Text(
        'Select Region',
        style: TextStyle(color: Colors.black45),
      ),
      decoration: InputDecoration(
        labelText: 'Select Region',
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      dropdownColor: Colors.white,
      onChanged: (String? newValue) {
        setState(() {
          _selectedRegion = newValue;
        });
      },
      items: regions.map<DropdownMenuItem<String>>((String region) {
        return DropdownMenuItem<String>(
          value: region,
          child: Text(region, style: const TextStyle(color: Colors.black)),
        );
      }).toList(),
    );
  }

  // Deadline Date Picker
  Widget _buildDeadlineField() {
    return GestureDetector(
      onTap: () => _selectDeadline(context),
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: _selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                : '',
          ),
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: 'Select Deadline',
            labelStyle: const TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}
