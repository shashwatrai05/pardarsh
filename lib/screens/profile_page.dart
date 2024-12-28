import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _displayName;
  String? _email;
  String? _role;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        _email = user.email;

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            _displayName = userDoc['legalName'];
            _role = userDoc['role'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/signin');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  void _openReviewContractorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double rating = 0.0;
        TextEditingController contractorEmailController =
            TextEditingController();
        TextEditingController reviewController = TextEditingController();
        return AlertDialog(
          title: const Text('Review Contractor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contractorEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Contractor Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('Rate the contractor:'),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 30,
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (value) {
                    rating = value;
                  },
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: reviewController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Write your review',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (rating > 0 &&
                    reviewController.text.isNotEmpty &&
                    contractorEmailController.text.isNotEmpty) {
                  try {
                    await _firestore.collection('reviews').add({
                      'userId': _auth.currentUser!.uid,
                      'contractorEmail': contractorEmailController.text,
                      'rating': rating,
                      'review': reviewController.text,
                      'timestamp': DateTime.now(),
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Review submitted successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill out all fields.')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepOrange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepOrange,
                        child: Text(
                          _displayName?.substring(0, 1).toUpperCase() ?? '',
                          style: const TextStyle(fontSize: 32, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _displayName ?? 'Name not available',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[800],
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _email ?? 'Email not available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                    const Divider(height: 32),
                    Center(
                      child: Text(
                        'Role: ${_role ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[800],
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Features:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.star, color: Colors.deepOrange),
                      title: const Text('Review a Contractor', style: TextStyle(color: Colors.black),),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _openReviewContractorDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.help_outline,
                          color: Colors.deepOrange),
                      title: const Text('Help Center', style: TextStyle(color: Colors.black),),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showDialog('Help Center',
                          'For assistance, contact support@pardarsh.com or visit our website.'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline,
                          color: Colors.deepOrange),
                      title: const Text('About Us', style: TextStyle(color: Colors.black),),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showDialog('About Us',
                          'This app promotes transparency in public tenders by enabling users to review contractors, view tender details, and much more.'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.question_answer,
                          color: Colors.deepOrange),
                      title: const Text('FAQs', style: TextStyle(color: Colors.black),),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showDialog('FAQs',
                          '1. How do I review a contractor?\n- Use the "Review a Contractor" feature.\n\n2. How do I log out?\n- Tap the "Logout" button at the bottom of the profile page.'),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Logout', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      backgroundColor: Colors.white,
    );
  }
}
