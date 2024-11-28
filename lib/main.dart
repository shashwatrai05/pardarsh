import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:public_tender_portal/models/user_model.dart';
import 'package:public_tender_portal/screens/contractor_dashboard.dart';
import 'package:public_tender_portal/screens/government_portal.dart';
import 'package:public_tender_portal/screens/homepage.dart';
import 'package:public_tender_portal/screens/profile_page.dart';
import 'package:public_tender_portal/screens/sign_in.dart';
import 'package:public_tender_portal/screens/sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCJpTXC9fl7BBwxxhCU7acy9o_w5v37z1U',
        appId: '1:765223655394:android:316be23b8c2e39f68f0bbb',
        messagingSenderId: '765223655394',
        projectId: 'shopping-app-ce5f7',
      ),
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Public Tender Portal',
      theme: ThemeData.dark(),
      home: const AuthWrapper(),
      routes: {
        '/signin': (context) => const SigninScreen(),
        '/signup': (context) => const SignupScreen(),
        '/homepage': (context) => const Homepage(),
        '/contractor_dashboard': (context) => const ContractorDashboard(),
        '/government_dashboard': (context) => const GovernmentPortal(),
        '/profile': (context) => const ProfilePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// New AuthWrapper widget
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _determineStartPage() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SigninScreen(); // Navigate to sign-in if no user is signed in
    }

    try {
      // Fetch user's role from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        UserModel loggedInUser = UserModel.fromFirestore(
          userDoc.data() as Map<String, dynamic>,
          userDoc.id,
        );

        switch (loggedInUser.role) {
          case 'Contractor':
            return const ContractorDashboard();
          case 'Government Official':
            return const GovernmentPortal();
          default: // General User
            return const Homepage();
        }
      }
    } catch (e) {
      debugPrint('Error determining user role: $e');
    }

    return const SigninScreen(); // Fallback in case of errors
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineStartPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        return snapshot.data!;
      },
    );
  }
}
