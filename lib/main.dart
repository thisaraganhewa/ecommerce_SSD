import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/constants.dart';
import 'package:ecom_app/pages/admin.dart';
import 'package:ecom_app/pages/cart.dart';
import 'package:ecom_app/pages/home.dart';
import 'package:ecom_app/pages/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart' as constraint;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: constraint.apikey,
        appId: constraint.appId,
        messagingSenderId: constraint.messagingSenderId,
        projectId: constraint.projectId,
      ),
    );
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }
  runApp(App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  // Function to validate email format
  bool isValidEmail(String email) {
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  // Function to sanitize email input
  String sanitizeEmail(String email) {
    return email.trim();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(),
        canvasColor: Colors.white,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: primaryColor,
          secondary: primaryColor,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, user) {
          if (user.hasData) {
            String? userEmail = user.data?.email;

            // Check if the email is valid and sanitized
            if (userEmail != null && isValidEmail(userEmail)) {
              String sanitizedEmail = sanitizeEmail(userEmail);

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("admin")
                    .where("email", isEqualTo: sanitizedEmail)
                    .snapshots(),
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.hasData) {
                    if (adminSnapshot.data!.size == 1) {
                      // If the user is an admin, navigate to AdminPage
                      return AdminPage();
                    } else {
                      // Otherwise, navigate to HomePage
                      return HomePage();
                    }
                  }
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    ),
                  );
                },
              );
            } else {
              // If email is invalid, navigate to RegisterPage
              return RegisterPage();
            }
          }
          // If no user is logged in, show RegisterPage
          return RegisterPage();
        },
      ),
    );
  }
}
