import 'package:ecom_app/components/footer.dart';
import 'package:ecom_app/components/my_button.dart';
import 'package:ecom_app/components/my_spacer.dart';
import 'package:ecom_app/constants.dart';
import 'package:ecom_app/helpers/change_screen.dart';
import 'package:ecom_app/pages/home.dart';
import 'package:ecom_app/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool showLoading = false;

  Future<void> _handleRegister() async {
    // Input validation
    if (!_isValidName(nameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid name. Name must contain only letters and spaces.")),
      );
      return;
    }

    if (!_isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email format")),
      );
      return;
    }

    if (!_isValidPassword(passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters and contain letters and numbers.")),
      );
      return;
    }

    setState(() {
      showLoading = true;
    });

    try {
      UserCredential userObj = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await userObj.user!.updateDisplayName(nameController.text);

      // Clear fields after successful registration
      emailController.clear();
      passwordController.clear();
      nameController.clear();

      // Navigate to HomePage
      changeScreenWithReplacement(context, HomePage());
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred";

      // Specific error handling for FirebaseAuth exceptions
      if (e.code == 'email-already-in-use') {
        errorMessage = "The email address is already in use.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is invalid.";
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = "Operation not allowed. Please contact support.";
      } else if (e.code == 'weak-password') {
        errorMessage = "The password is too weak.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        showLoading = false;
      });
    }
  }

  // Name validation method
  bool _isValidName(String name) {
    final RegExp nameRegExp = RegExp(r"^[a-zA-Z ]+$");
    return name.isNotEmpty && nameRegExp.hasMatch(name);
  }

  // Email validation method
  bool _isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegExp.hasMatch(email);
  }

  // Password validation method
  bool _isValidPassword(String password) {
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
    return passwordRegExp.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sign Up",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
            VerticalSpacer(12),
            SizedBox(
              width: 250,
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  label: Text("Name"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            VerticalSpacer(12),
            SizedBox(
              width: 250,
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  label: Text("Email"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            VerticalSpacer(8),
            SizedBox(
              width: 250,
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  label: Text("Password"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true, // Ensures the password is not visible
              ),
            ),
            VerticalSpacer(8),
            showLoading
                ? CircularProgressIndicator(
                    color: primaryColor,
                  )
                : MyButton(
                    text: "Submit",
                    onPressed: _handleRegister,
                  ),
            InkWell(
              onTap: () {
                changeScreen(
                  context,
                  LoginPage(),
                );
              },
              child: Text(
                "Already a user? Sign In",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
