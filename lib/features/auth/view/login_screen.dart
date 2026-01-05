import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeup/features/admin/admin_dashboard.dart';
import 'package:codeup/features/bottomnav/view/bottomnav_screen.dart';
import 'package:codeup/features/auth/view/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/variables/global_variables.dart';
import '../model/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email (e.g., user@example.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserToPreferences(
    String uid,
    String email,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('email', email);
  }

  Future<void> _handleLogin() async {
    _clearErrors();
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String email = emailController.text.trim();
        String password = passwordController.text.trim();

        // First check if user exists in Firestore
        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          // User not found in database
          setState(() {
            _isLoading = false;
            _emailError = 'No account found with this email. Please sign up first.';
          });
          return;
        }

        // User exists, check status
        final userData = userQuery.docs.first.data();
        final status = userData['status'] as int;
        final uid = userData['uid'] as String;
        final name = userData['name'] as String;

        if (status == 0) {
          // User is blocked
          setState(() {
            _isLoading = false;
            _emailError = 'Your account has been blocked. Please contact support.';
          });
          return;
        } else if (status == -1) {
          // User account was deleted
          setState(() {
            _isLoading = false;
            _emailError = 'Your account was deleted. Please sign up again to reactivate.';
          });
          return;
        }

        // Status is 1 (active), proceed with Firebase Auth login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save user data to SharedPreferences
        await _saveUserToPreferences(uid, email);

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );
          final userModel = UserModel.fromJson(userData);
          globalUser = userModel;

          // Navigate based on user type
          if (email == 'admin@gmail.com') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const BottomnavScreen()),
              (route) => false,
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Handle different Firebase Auth error codes
        if (e.code == 'user-not-found') {
          setState(() {
            _emailError = 'No account found with this email.';
          });
        } else if (e.code == 'wrong-password') {
          setState(() {
            _passwordError = 'Incorrect password. Please try again.';
          });
        } else if (e.code == 'invalid-email') {
          setState(() {
            _emailError = 'Invalid email format.';
          });
        } else if (e.code == 'invalid-credential') {
          // Handle invalid credentials (email or password is wrong)
          setState(() {
            _emailError = 'Invalid email or password.';
            _passwordError = 'Invalid email or password.';
          });
        } else if (e.code == 'user-disabled') {
          setState(() {
            _emailError = 'This account has been disabled.';
          });
        } else if (e.code == 'too-many-requests') {
          setState(() {
            _emailError = 'Too many login attempts. Please try again later.';
          });
        } else if (e.code == 'network-request-failed') {
          setState(() {
            _emailError = 'Network error. Please check your connection.';
          });
        } else {
          // Generic error message for unknown errors
          setState(() {
            _emailError = 'Login failed: ${e.message ?? 'Please try again.'}';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.code}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } on PlatformException catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Handle PlatformException errors from Firebase
        if (e.code == 'invalid-credential') {
          setState(() {
            _emailError = 'Invalid email or password.';
            _passwordError = 'Invalid email or password.';
          });
        } else if (e.code == 'network-request-failed') {
          setState(() {
            _emailError = 'Network error. Please check your connection.';
          });
        } else if (e.code == 'too-many-requests') {
          setState(() {
            _emailError = 'Too many login attempts. Please try again later.';
          });
        } else {
          setState(() {
            _emailError = 'Login failed. Please check your credentials.';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.message ?? e.code}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                // Title
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please sign in to continue",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // Email Input
                TextFormField(
                  controller: emailController,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => _clearErrors(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: "Email",
                    labelText: "Email",
                    helperText: _emailError != null ? null : 'Enter your registered email',
                    errorText: _emailError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _emailError != null ? Colors.red : Colors.grey[300]!,
                        width: _emailError != null ? 2 : 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _emailError != null ? Colors.red : Colors.blue,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // Password Input
                TextFormField(
                  controller: passwordController,
                  validator: _validatePassword,
                  obscureText: _obscurePassword,
                  onChanged: (_) => _clearErrors(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    hintText: "Password",
                    labelText: "Password",
                    helperText: _passwordError != null ? null : 'Minimum 6 characters',
                    errorText: _passwordError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _passwordError != null ? Colors.red : Colors.grey[300]!,
                        width: _passwordError != null ? 2 : 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _passwordError != null ? Colors.red : Colors.blue,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.blue[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "LOGIN",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign Up Link
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[700], fontSize: 15),
                      children: [
                        TextSpan(
                          text: "Sign up",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                        ),
                      ],
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
}