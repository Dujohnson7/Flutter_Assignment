
import 'package:flutter/material.dart';
import 'todos_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/avatar.jpg',
              width: 150,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Simulate successful login
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const TodosScreen()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}