import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';  // Add this dependency for rating functionality
import 'package:public_tender_portal/screens/profile_page.dart';
import 'detail_screen.dart';  // Import the ProjectDetailsScreen // Import the Profile screen

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  String? _userRole;
  String? _selectedRegion;
  List<DocumentSnapshot> _projects = [];
  bool _isLoadingProjects = false;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userRole = userDoc['role'];
      });
    }
  }

  Future<void> _fetchProjectsForRegion(String region) async {
    setState(() {
      _isLoadingProjects = true;
    });

    QuerySnapshot projectQuery = await FirebaseFirestore.instance
        .collection('projects')
        .where('region', isEqualTo: region)
        .get();

    setState(() {
      _projects = projectQuery.docs;
      _isLoadingProjects = false;
    });
  }

  Widget _buildGeneralUserHome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          _buildUserInfo(),
          SizedBox(height: 20),
          _buildCarouselSection(),
          SizedBox(height: 20),
          _buildNotifications(),
          SizedBox(height: 20),
          _buildStaticInformation(),
          SizedBox(height: 20),
          _buildOngoingProjectsSection(),
          SizedBox(height: 20),
          _buildRegionSelectionSection(),
          SizedBox(height: 20),
          _buildProjectsSection(),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepOrange,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Welcome, Citizen of India',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSection() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180.0,
        autoPlay: true,
        enlargeCenterPage: true,
        autoPlayInterval: Duration(seconds: 4),
      ),
      items: [
        'assets/tender_image_1.jpg',
        'assets/tender_image_2.jpg',
        'assets/tender_image_3.jpg',
      ].map((imgPath) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imgPath,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildNotifications() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.deepOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: const [
            Icon(Icons.notifications, color: Colors.deepOrange),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'New tenders have been posted! Check them out now.',
                style: TextStyle(color: Colors.deepOrange, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticInformation() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to the Government Tender Portal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Find the latest public tenders for government projects.',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 20),
          Text(
            'How It Works: ',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange),
          ),
          SizedBox(height: 10),
          Text(
            '1. Select your region to view available tenders.',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          Text(
            '2. Browse through the list of tenders for each project.',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          Text(
            '3. Submit your bids online and track their progress.',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingProjectsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildOngoingProjectsCard('Total Ongoing Projects', '12', Icons.assignment),
            _buildOngoingProjectsCard('Total Budget', '₹30,00,000', Icons.monetization_on),
            _buildOngoingProjectsCard('Projects in Region', '2', Icons.location_on),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingProjectsCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepOrange),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 20, color: Colors.deepOrange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSelectionSection() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          String? selected = await showModalBottomSheet<String>(
            context: context,
            builder: (BuildContext context) {
              return ListView(
                children: ['Ghaziabad', 'Noida'].map((region) {
                  return ListTile(
                    title: Text(region),
                    onTap: () => Navigator.pop(context, region),
                  );
                }).toList(),
              );
            },
          );
          if (selected != null) {
            setState(() {
              _selectedRegion = selected;
            });
            _fetchProjectsForRegion(selected);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Select Region', style: TextStyle(color: Colors.white)),
      ),
    );
  }

 Widget _buildProjectsSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: _isLoadingProjects
        ? Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Projects',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _projects.length,
                itemBuilder: (context, index) {
                  var project = _projects[index].data() as Map<String, dynamic>;
                  // Safely access the fields with fallback values
                  String title = project['name'] ?? 'No Title';
                  String region = project['region'] ?? 'Unknown Region';
                  double rating = project['rating'] ?? 0.0;

                  return Card(
  color: Colors.white, // Light color for a clean look on a white background
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  elevation: 6,
  margin: EdgeInsets.symmetric(vertical: 10),
  child: ListTile(
    contentPadding: EdgeInsets.all(16), // Added padding for a better look
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.deepOrange, // Highlighted text for contrast
      ),
    ),
    subtitle: Text(
      'Location: $region',
      style: TextStyle(color: Colors.grey[600]), // Subtle text color
    ),
    trailing: RatingBar.builder(
      unratedColor: Colors.grey[100],
      glowColor: Colors.blueGrey,
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 20,
      itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
      onRatingUpdate: (rating) {
        // Handle rating logic here (e.g., save to Firestore)
      },
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectDetailsScreen(
            projectName: project['name'] ?? 'Unnamed Project',
            projectRegion: project['region'] ?? 'Unknown Region',
            projectDetails: project['tenderDetails'] ?? 'No tender details available',
            deadline: project['deadline'] ?? 'No deadline specified',
            status: project['status'] ?? 'Status Unknown',
            contractorEmail: project['contractorId'] ?? 'No contractor email provided',
            description: project['description'] ?? 'No description available',
          ),
        ),
      );
    },
  ),
);

                },
              ),
            ],
          ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tender Portal'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: _userRole == null
          ? Center(child: CircularProgressIndicator())
          : _userRole == 'General User'
              ? _buildGeneralUserHome()
              : Center(child: Text('No content available for this role')),
    );
  }
}
