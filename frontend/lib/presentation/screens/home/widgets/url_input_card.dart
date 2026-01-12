import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/media_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';

/// URL input card widget
class URLInputCard extends StatefulWidget {
  const URLInputCard({super.key});

  @override
  State<URLInputCard> createState() => _URLInputCardState();
}

class _URLInputCardState extends State<URLInputCard> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      _controller.text = clipboardData.text!;
    }
  }

  void _clear() {
    _controller.clear();
  }

  void _analyze() {
    if (_formKey.currentState!.validate()) {
      final url = _controller.text.trim();
      context.read<MediaProvider>().analyzeUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Row(
                children: [
                  const Icon(Icons.link, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Enter URL',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // URL Input Field
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'https://www.example.com/video',
                  prefixIcon: const Icon(Icons.public),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clear,
                        )
                      : null,
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                validator: Validators.validateUrl,
                onChanged: (value) {
                  setState(() {}); // Update to show/hide clear button
                },
                onFieldSubmitted: (_) => _analyze(),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pasteFromClipboard,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.content_paste, size: 18),
                          SizedBox(width: 6),
                          Text('Paste'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Consumer<MediaProvider>(
                      builder: (context, provider, child) {
                        return ElevatedButton(
                          onPressed: provider.isAnalyzing ? null : _analyze,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (provider.isAnalyzing)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              else
                                const Icon(Icons.search, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                provider.isAnalyzing
                                    ? 'Analyzing...'
                                    : 'Analyze',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
