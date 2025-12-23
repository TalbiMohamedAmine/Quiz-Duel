import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    // Sign in anonymously if not already signed in
    _user = _authService.currentUser ?? await _authService.signInAnonymously();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Duel')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hello, user: ${_user!.uid.substring(0, 6)}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // will connect to create-room later
              },
              child: const Text('Create Room'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // will connect to join-room later
              },
              child: const Text('Join Room'),
            ),
          ],
        ),
      ),
    );
  }
}
