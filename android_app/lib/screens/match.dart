
import 'package:flutter/material.dart';

import '../services/api.dart';
import '../services/store.dart';
import '../widgets/result.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late final TextEditingController resume;
  final TextEditingController job = TextEditingController();

  String out = '';
  bool busy = false;

  @override
  void initState() {
    super.initState();

    resume = TextEditingController(
      text: Store.resume,
    );
  }

  @override
  void dispose() {
    resume.dispose();
    job.dispose();
    super.dispose();
  }

  Future<void> run() async {
    if (resume.text.trim().isEmpty) {
      setState(() {
        out = 'Please enter your resume before comparing.';
      });
      return;
    }

    if (job.text.trim().isEmpty) {
      setState(() {
        out = 'Please enter a job description before comparing.';
      });
      return;
    }

    setState(() {
      busy = true;
      out = '';
    });

    try {
      final r = await Api.post(
        '/jobs/match',
        {
          'resume_text': resume.text.trim(),
          'job_description': job.text.trim(),
        },
      );

      if (!mounted) return;

      final score = r['keyword_score'] ?? 'N/A';
      final matched = r['keywords_found'] ?? 'None';
      final gaps = r['keyword_gaps'] ?? 'None';
      final analysis = r['analysis'] ?? 'No analysis returned.';

      setState(() {
        out = '''
Keyword heuristic score: $score%

Matched:
$matched

Gaps:
$gaps

Analysis:
$analysis
''';
      });

      await Store.log('Job match');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        out = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Match'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text(
            'Compare your resume with a job posting.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Resume input
          TextField(
            controller: resume,
            minLines: 4,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Resume',
              hintText: 'Paste your resume here...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 14),

          // Job description input
          TextField(
            controller: job,
            minLines: 7,
            maxLines: 15,
            decoration: const InputDecoration(
              labelText: 'Job posting',
              hintText: 'Paste the job description here...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 18),

          // Compare button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: busy ? null : run,
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Compare Resume'),
            ),
          ),

          const SizedBox(height: 12),

          // Loading indicator
          if (busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 10),
            const Center(
              child: Text('Analyzing your resume...'),
            ),
          ],

          // Analysis result
          if (out.isNotEmpty) ...[
            const SizedBox(height: 16),

            Result(
              title: 'Job Match Analysis',
              text: out,
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
