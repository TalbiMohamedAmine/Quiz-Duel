import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  User? _user;
  bool _loading = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateDisplayName(User user, String name) async {
    if (name.isEmpty) return;
    await user.updateDisplayName(name);
    await user.reload();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _handleAnonymous() async {
    final name = _nameController.text.trim();
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final user = await _authService.signInAnonymously();
      if (user != null && name.isNotEmpty) {
        await _updateDisplayName(user, name);
      }
    } catch (e) {
      setState(() => _error = 'Anonymous sign‑in failed');
    } finally {
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
        _loading = false;
      });
    }
  }

  Future<void> _handleEmailSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email and password required');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final user = await _authService.signInWithEmail(email, password);
      final name = _nameController.text.trim();
      if (user != null && name.isNotEmpty) {
        await _updateDisplayName(user, name);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Email sign‑in failed');
    } finally {
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
        _loading = false;
      });
    }
  }

  Future<void> _handleEmailSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Name, email and password required');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final user = await _authService.signUpWithEmail(email, password);
      if (user != null) {
        await _updateDisplayName(user, name);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Sign up failed');
    } finally {
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
        _loading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      await _authService.signOut();
    } catch (e) {
      setState(() => _error = 'Sign out failed');
    } finally {
      setState(() {
        _user = null;
        _loading = false;
      });
    }
  }

  Future<void> _handleSendVerificationEmail() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      await _authService.sendEmailVerification();
      setState(() => _success = 'Verification email sent! Check your inbox.');
    } catch (e) {
      setState(() => _error = 'Failed to send verification email');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleSendPasswordReset() async {
    final email = _user?.email;
    if (email == null || email.isEmpty) {
      setState(() => _error = 'No email associated with this account');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      await _authService.sendPasswordResetEmail(email);
      setState(() => _success = 'Password reset email sent to $email');
    } catch (e) {
      setState(() => _error = 'Failed to send password reset email');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleUpdatePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty) {
      setState(() => _error = 'Please enter your current password');
      return;
    }
    if (newPassword.isEmpty || newPassword.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _error = 'New passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      await _authService.updatePassword(oldPassword, newPassword);
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _success = 'Password updated successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        setState(() => _error = 'Current password is incorrect');
      } else if (e.code == 'requires-recent-login') {
        setState(() => _error = 'Please sign out and sign in again to change password');
      } else {
        setState(() => _error = e.message ?? 'Failed to update password');
      }
    } catch (e) {
      setState(() => _error = 'Failed to update password');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshUser() async {
    try {
      await _user?.reload();
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
        _success = 'Account info refreshed';
      });
    } catch (e) {
      setState(() => _error = 'Failed to refresh');
    }
  }

  Widget _buildLoggedInView() {
    final displayName = _user?.displayName ??
        (_user?.isAnonymous == true ? 'Guest' : _user?.email ?? 'Unknown');
    final isAnonymous = _user?.isAnonymous ?? false;
    final email = _user?.email;
    final emailVerified = _user?.emailVerified ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Account Info Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (email != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    email,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  emailVerified ? Icons.verified : Icons.warning,
                                  size: 16,
                                  color: emailVerified ? Colors.green : Colors.orange,
                                ),
                              ],
                            ),
                          ],
                          if (isAnonymous)
                            Text(
                              'Guest Account',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refreshUser,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Email Verification Section (only for non-anonymous, non-verified users)
        if (!isAnonymous && email != null && !emailVerified) ...[
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Email Not Verified',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Verify your email to secure your account.'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _handleSendVerificationEmail,
                    icon: const Icon(Icons.send),
                    label: const Text('Send Verification Email'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Account Settings Section (only for non-anonymous users)
        if (!isAnonymous) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // Change Password Section
                  Text(
                    'Change Password',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _oldPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your current password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                      hintText: 'Enter new password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                      hintText: 'Re-enter new password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleUpdatePassword,
                      child: const Text('Update Password'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('Forgot your password? ', style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: _handleSendPasswordReset,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Send Reset Email'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Sign Out Button
        ElevatedButton.icon(
          onPressed: _handleSignOut,
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name (used in game)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleEmailSignIn,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Sign in with Email'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleEmailSignUp,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Sign up with Email'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _handleAnonymous,
            child: const Text('Continue as Guest'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_user != null ? 'My Account' : 'Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_user != null)
                _buildLoggedInView()
              else
                _buildLoginView(),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_success != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _success!,
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
