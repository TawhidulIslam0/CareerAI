
// ignore_for_file: unused_import

import 'package:flutter/material.dart';

import '../services/store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App information
          Text(
            'CareerAI',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 6),

          const Text(
            'Your career assistant, powered by AI.',
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // Subscription plans
          Text(
            'Subscription Plans',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.calendar_month,
                color: Colors.deepPurple,
              ),
              title: const Text('Monthly Pro'),
              subtitle: const Text('Coming soon'),
              trailing: const Text(
                '\$4.99/mo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.workspace_premium,
                color: Colors.amber,
              ),
              title: const Text('Lifetime Pro'),
              subtitle: const Text('Coming soon'),
              trailing: const Text(
                '\$14.99',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Privacy
          Text(
            'Privacy',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Your Privacy'),
              subtitle: const Text(
                'Your resume and application records are stored locally on your device. '
                'AI requests are processed through your configured AI service.',
              ),
            ),
          ),

          const SizedBox(height: 24),

          // About
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 8),

          Card(
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('CareerAI'),
              subtitle: Text('Version 1.0.0'),
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              'Made for your career growth.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
