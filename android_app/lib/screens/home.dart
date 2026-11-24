
import 'package:flutter/material.dart';

import '../services/api.dart';
import '../services/store.dart';
import '../widgets/feature.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String health = 'Checking local AI connection';

  @override
  void initState() {
    super.initState();
    check();
  }

  Future<void> check() async {
    try {
      final response = await Api.get('/health');

      if (!mounted) return;

      setState(() {
        health =
            'Server online · '
            'Ollama ${response['ollama']} · '
            'model ready ${response['model_ready']}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        health =
            'Backend not connected · Start backend on your PC';
      });
    }
  }

  List<String> get history {
    final data = Store.b.get(
      'history',
      defaultValue: <String>[],
    );

    if (data is List) {
      return data.whereType<String>().toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final recentHistory = history.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareerAI'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero section
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xff7967e9),
                  Color(0xff5141b3),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your career.\nYour local AI.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Career tools powered by Qwen on your own PC.',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  health,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: check,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Check connection',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Career toolkit
          Text(
            'Career toolkit',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 8),

          const Feature(
            icon: Icons.description,
            title: 'Resume Studio',
            sub: 'Upload, edit, analyze, improve and export',
            route: '/resume',
          ),

          const Feature(
            icon: Icons.compare_arrows,
            title: 'Job Match',
            sub: 'Match resume to a job posting',
            route: '/match',
          ),

          const Feature(
            icon: Icons.mail_outline,
            title: 'Cover Letter',
            sub: 'Draft a role-specific cover letter',
            route: '/cover',
          ),

          const Feature(
            icon: Icons.record_voice_over,
            title: 'Interview practice',
            sub: 'Question sets and feedback',
            route: '/interview',
          ),

          const Feature(
            icon: Icons.track_changes,
            title: 'Application tracker',
            sub: 'Track applications and progress',
            route: '/tracker',
          ),

          const Feature(
            icon: Icons.settings,
            title: 'Settings & plans',
            sub: 'Backend connection and pricing setup',
            route: '/settings',
          ),

          // Saved resume information
          if (Store.resume.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Resume saved locally'),
                  subtitle: Text(
                    '${Store.resume.split(RegExp(r'\s+')).length} words',
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Recent activity
          Text(
            'Recent activity',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          if (recentHistory.isNotEmpty)
            ...recentHistory.map(
              (activity) => Card(
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.history),
                  title: Text(activity),
                ),
              ),
            )
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.grey),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Activity history will appear here after using a tool.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
