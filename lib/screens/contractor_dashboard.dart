import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:public_tender_portal/screens/project_details_screen.dart';

class ContractorDashboard extends StatefulWidget {
  const ContractorDashboard({super.key});

  @override
  State<ContractorDashboard> createState() => _ContractorDashboardState();
}

class _ContractorDashboardState extends State<ContractorDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> _projects = [];
  bool _isLoading = true;
  String? _contractorEmail;

  @override
  void initState() {
    super.initState();
    _getContractorEmail();
  }

  // Get the logged-in contractor's email and fetch projects assigned to them
  Future<void> _getContractorEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _contractorEmail = user.email;  // Use the email as the contractor ID
      });
      await _fetchProjects(user.email!);  // Fetch projects after contractor email is available
    }
  }

  Future<void> _fetchProjects(String contractorEmail) async {
    try {
      // Fetch projects assigned to the logged-in contractor's email
      QuerySnapshot querySnapshot = await _firestore
          .collection('projects')
          .where('contractorId', isEqualTo: contractorEmail)
          .get();
      setState(() {
        _projects = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching projects: ${e.toString()}')));
    }
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

  void _openProjectDetails(DocumentSnapshot project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(project: project),
      ),
    );
  }

  Future<void> _refreshProjects() async {
    setState(() {
      _isLoading = true;
    });
    if (_contractorEmail != null) {
      await _fetchProjects(_contractorEmail!);  // Reload the projects based on contractor email
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Contractor Dashboard'),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.blue),
        titleTextStyle: const TextStyle(color: Colors.blue, fontSize: 18),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.blue),
          )
        ],
      ),
      body: RefreshIndicator(
        color: Colors.white54,
        backgroundColor: Colors.blueGrey,
        onRefresh: _refreshProjects, // Trigger refresh when the user swipes down
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _projects.isEmpty
                ? const Center(child: Text('No projects assigned.'))
                : ListView.builder(
                    itemCount: _projects.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot project = _projects[index];
                      return Card(
                        color: Colors.white,
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            project['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          subtitle: Text(
                            'Region: ${project['region']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blue,
                          ),
                          onTap: () => _openProjectDetails(project),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
