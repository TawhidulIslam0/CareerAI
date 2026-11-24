
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/api.dart';
import '../services/store.dart';
import '../utils/ats.dart';
import '../utils/export_pdf.dart';
import '../widgets/result.dart';

class ResumePage extends StatefulWidget {
  const ResumePage({super.key});

  @override
  State<ResumePage> createState() => _ResumeState();
}

class _ResumeState extends State<ResumePage> {
  late TextEditingController text;

  String output = '';
  bool busy = false;

  @override
  void initState() {
    super.initState();
    text = TextEditingController(text: Store.resume);
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  // Import PDF or DOCX resume
  Future<void> upload() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );

      if (file == null) return;

      if (file.path == null) {
        if (!mounted) return;

        setState(() {
          output = 'Unable to access this file on your device.';
        });
        return;
      }

      setState(() {
        busy = true;
        output = '';
      });

      final response = await Api.upload(
        file.path!,
        file.name,
      );

      if (!mounted) return;

      final extractedText = response['resume_text'];

      if (extractedText == null ||
          extractedText.toString().trim().isEmpty) {
        setState(() {
          output = 'No text could be extracted from this file.';
        });
        return;
      }

      text.text = extractedText.toString();

      await Store.saveResume(text.text);

      if (!mounted) return;

      setState(() {
        output =
            'Successfully imported ${file.name}.\n\n'
            'Your resume has been extracted and saved.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        output = 'Upload error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  // Save resume locally
  Future<void> save() async {
    if (text.text.trim().isEmpty) {
      setState(() {
        output = 'Please enter your resume before saving.';
      });
      return;
    }

    try {
      await Store.saveResume(text.text);

      if (!mounted) return;

      setState(() {
        output = 'Resume saved successfully!';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        output = 'Save failed: $e';
      });
    }
  }

  // AI resume operations
  Future<void> ai(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    if (text.text.trim().isEmpty) {
      setState(() {
        output = 'Please enter or import a resume first.';
      });
      return;
    }

    setState(() {
      busy = true;
      output = '';
    });

    try {
      final response = await Api.post(endpoint, data);

      if (!mounted) return;

      final result = response.values.firstWhere(
        (value) =>
            value is String && value.trim().isNotEmpty,
        orElse: () => response.toString(),
      );

      setState(() {
        output = result.toString();
      });

      await Store.log(endpoint);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        output = 'Request failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  // ATS compatibility check
  Future<void> atsCheck() async {
    if (text.text.trim().isEmpty) {
      setState(() {
        output = 'Please enter your resume first.';
      });
      return;
    }

    try {
      final result = Ats.run(text.text, '');

      setState(() {
        output = result.toString();
      });

      await Store.log('ATS check');
    } catch (e) {
      setState(() {
        output = 'ATS check failed: $e';
      });
    }
  }

  // Export PDF
  Future<void> export() async {
    if (text.text.trim().isEmpty) {
      setState(() {
        output = 'Please enter a resume before exporting.';
      });
      return;
    }

    try {
      await exportPdf(text.text);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        output = 'PDF export failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Studio'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          OutlinedButton.icon(
            onPressed: busy ? null : upload,
            icon: const Icon(Icons.upload_file),
            label: const Text('Import PDF or DOCX'),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: text,
            minLines: 8,
            maxLines: 20,
            decoration: const InputDecoration(
              labelText: 'Resume text',
              hintText: 'Paste or edit your resume here...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => ai(
                          '/resume/analyze',
                          {
                            'resume_text': text.text,
                          },
                        ),
                icon: const Icon(Icons.analytics),
                label: const Text('Analyze'),
              ),

              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => ai(
                          '/resume/improve',
                          {
                            'resume_text': text.text,
                            'section': 'whole resume',
                          },
                        ),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Improve'),
              ),

              OutlinedButton.icon(
                onPressed: busy ? null : atsCheck,
                icon: const Icon(Icons.fact_check),
                label: const Text('ATS Check'),
              ),

              OutlinedButton.icon(
                onPressed: busy ? null : save,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),

              OutlinedButton.icon(
                onPressed: busy ? null : export,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 10),
            const Center(
              child: Text('Processing your resume...'),
            ),
          ],

          if (output.isNotEmpty) ...[
            const SizedBox(height: 12),

            Result(
              title: 'Resume Studio Result',
              text: output,
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
