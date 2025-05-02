import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'device_manager_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      debugPrint('Attempting to sign in with email: $email');

      // Check if Firebase is initialized
      if (!Firebase.apps.isNotEmpty) {
        debugPrint('Firebase not initialized, attempting to initialize...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Try to sign in
      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        debugPrint('Firebase Auth successful. User ID: ${userCredential.user?.uid}');

        // Get the UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        debugPrint('Loading user data from Firestore...');
        // Load user data
        await userProvider.loadUser();

        if (!mounted) return;

        // Check if user data was loaded successfully
        if (userProvider.error != null) {
          debugPrint('Error loading user data: ${userProvider.error}');
          setState(() {
            _errorMessage = userProvider.error;
            _isLoading = false;
          });
          return;
        }

        debugPrint('User data loaded successfully: ${userProvider.user?.name}');

        // Clear any previous error messages
        ScaffoldMessenger.of(context).clearSnackBars();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Welcome back, ${userProvider.user?.name ?? "User"}!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return;

      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuthException during login: ${e.code} - ${e.message}');
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No account found with this email. Please register first.';
            // Show registration suggestion
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('No account found. Would you like to register?'),
                    ),
                  ],
                ),
                action: SnackBarAction(
                  label: 'Register',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterScreen(initialEmail: email),
                      ),
                    );
                  },
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 8),
              ),
            );
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid email or password. Please check your credentials.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your internet connection.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many failed attempts. Please try again later.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password sign in is not enabled. Please contact support.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    } finally {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(
          initialEmail: _emailController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 64,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // App Name
                    const Text(
                      'AutoFarmer',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Smart Farming Solutions',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: _validateEmail,
                      enabled: !_isLoading,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: _validatePassword,
                      enabled: !_isLoading,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade100.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    
                    // Login Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.green.withOpacity(0.5),
                        elevation: 2,
                        shadowColor: Colors.green.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Register Link
                    if (!_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToRegister,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
