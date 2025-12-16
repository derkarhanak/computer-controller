import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/app_state.dart';
import '../models/message.dart';
import '../services/llm_service.dart';
import '../services/python_executor.dart';
import 'widgets/code_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final LLMService _llmService = LLMService();
  final PythonExecutor _pythonExecutor = PythonExecutor();

  @override
  Widget build(BuildContext context) {
    // Check for pending input
    final appState = Provider.of<AppState>(context);
    final pendingInput = appState.consumePendingInput();
    if (pendingInput != null) {
      _controller.text = pendingInput;
    }

    return Column(
      children: [
        // Custom Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF333333))),
          ),
          child: Row(
            children: [
              Text(
                'Chat & Control',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear Chat',
                onPressed: () {
                  appState.clearMessages();
                },
              ),
            ],
          ),
        ),
        // Main Content
        Expanded(
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              if (appState.messages.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.terminal, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Enter a command to control your computer',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: appState.messages.length,
                itemBuilder: (context, index) {
                  final message = appState.messages[index];
                  return _buildMessageItem(message);
                },
              );
            },
          ),
        ),
        if (appState.isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a command (e.g., "Create a file...")',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(LogMessage message) {
    return Align(
      alignment: message.role == MessageRole.user
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.role == MessageRole.user
              ? Colors.blueAccent.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: message.role == MessageRole.user
                ? Colors.blueAccent.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  message.role == MessageRole.user
                      ? Icons.person
                      : Icons.smart_toy,
                  size: 16,
                  color: message.role == MessageRole.user
                      ? Colors.blueAccent
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  message.role == MessageRole.user ? 'You' : 'Assistant',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (message.role == MessageRole.user) ...[
                  const SizedBox(width: 8),
                  Consumer<AppState>(
                    builder: (context, appState, child) {
                      final isSaved = appState.isCommandSaved(message.content);
                      return InkWell(
                        onTap: () =>
                            appState.toggleSavedCommand(message.content),
                        child: Icon(
                          isSaved ? Icons.star : Icons.star_border,
                          size: 16,
                          color: isSaved ? Colors.yellowAccent : Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            message.content.isNotEmpty
                ? MarkdownBody(data: message.content)
                : const SizedBox.shrink(),
            if (message.hasCode)
              CodePreview(
                code: message.generatedCode!,
                onRun: () => _executeCode(message.generatedCode!),
                onCancel: () {
                  // Just show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Execution cancelled')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final appState = Provider.of<AppState>(context, listen: false);

    // Clear input
    _controller.clear();

    // Add User Message
    appState.addMessage(LogMessage(content: text, role: MessageRole.user));

    appState.setLoading(true);

    try {
      final history = appState.messages
          .where((m) => m.role != MessageRole.system)
          .map((m) => {'role': m.role.name, 'content': m.content})
          .toList();

      final response = await _llmService.generateResponse(
        provider: appState.selectedProvider,
        model: appState.selectedModel,
        apiKey: appState.apiKey,
        prompt: text,
        history: history,
      );

      // Parse code block
      String? code;
      String content = response;

      final codeBlockRegex = RegExp(r'```python([\s\S]*?)```');
      final match = codeBlockRegex.firstMatch(response);
      if (match != null) {
        code = match.group(1)?.trim();
        // Option: Remove code from content if we want, but keeping it is fine for context.
        // content = response.replaceFirst(match.group(0)!, '').trim();
      }

      appState.addMessage(
        LogMessage(
          content: content,
          role: MessageRole.assistant,
          generatedCode: code,
        ),
      );

      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      appState.addMessage(
        LogMessage(content: 'Error: $e', role: MessageRole.system),
      );
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> _executeCode(String code) async {
    final appState = Provider.of<AppState>(context, listen: false);

    // Show executing status
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Executing code...')));

    final result = await _pythonExecutor.executeScript(code);

    String outputMessage;
    if (result.isSuccess) {
      outputMessage =
          '### Execution Successful ✅\n\nCommand Output:\n```\n${result.stdout}\n```';
    } else {
      outputMessage =
          '### Execution Failed ❌\n\nError:\n```\n${result.stderr}\n```';
    }

    appState.addMessage(
      LogMessage(
        content: outputMessage,
        role: MessageRole.system, // Using system role for execution results
      ),
    );
  }
}
