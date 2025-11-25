// import 'package:codeup/features/bottomnav/view/bottomnav_screen.dart';
// import 'package:codeup/features/home/view/home_screen.dart';
// import 'package:codeup/features/auth/view/signup_screen.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   TextEditingController emailcontroller = TextEditingController();
//   TextEditingController passwordcontroller = TextEditingController();
//   final TextEditingController mobileController = TextEditingController();

//   void _handleLogin() {
//     // In a real app, you would add validation and API calls here.

//     print("Logging in with: ${emailcontroller.text}");

//     // 2. NAVIGATE TO HOMESCREEN
//     // pushReplacement prevents the user from going back to the Login screen
//     // using the system back button after a successful login.
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const BottomnavScreen(), // Navigate to HomeScreen
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F4F2),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               const Text(
//                 "Login",
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Please sign in to continue.",
//                 style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//               ),
//               const SizedBox(height: 40),

//               // Email Input
//               TextField(
//                 controller: emailcontroller,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Icons.email_outlined),
//                   hintText: "Email",
//                   border: UnderlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Password Input with 'Forgot'
//               TextField(
//                 controller: passwordcontroller,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Icons.lock_outline),
//                   hintText: "Password",
//                   border: UnderlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 40),

//               // Login Button
//               Center(
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton.icon(
//                     // 3. CALL THE NAVIGATION FUNCTION
//                     onPressed: _handleLogin,

//                     icon: const Icon(Icons.arrow_forward, color: Colors.white),
//                     label: const Text(
//                       "LOGIN",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),

//               // Sign Up Link
//               Center(
//                 child: Text.rich(
//                   TextSpan(
//                     text: "Don’t have an account? ",
//                     style: const TextStyle(color: Colors.grey),
//                     children: [
//                       TextSpan(
//                         text: "Sign up",
//                         style: const TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => const SignupScreen(),
//                               ),
//                             );
//                           },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:codeup/features/bottomnav/view/bottomnav_screen.dart';
import 'package:codeup/features/auth/view/signup_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Example: You can later replace this with your actual Admin screen.


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String selectedRole = "User"; // Default selection

  void _handleLogin() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Example: simple role-based logic (replace with your backend validation)
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    print("Logging in as $selectedRole with email: $email");

    // Navigate based on role
    if (selectedRole == "Admin") {
      // Navigator.pushReplacement(
      //   context,
      //   // MaterialPageRoute(
      //   //   builder: (context) => const AdminHomeScreen(),
      //   // ),
      // );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BottomnavScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please sign in to continue.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Email Input
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: "Email",
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Password Input
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  hintText: "Password",
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // 🔹 Role Selection (Admin/User)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: "User",
                    groupValue: selectedRole,
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const Text("User"),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: "Admin",
                    groupValue: selectedRole,
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const Text("Admin"),
                ],
              ),
              const SizedBox(height: 30),

              // Login Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _handleLogin,
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Sign Up Link
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "Don’t have an account? ",
                    style: const TextStyle(color: Colors.grey),
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
    );
  }
}
