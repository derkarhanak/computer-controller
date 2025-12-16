import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/message.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF333333))),
          ),
          child: Row(
            children: [
              Text(
                'History',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              if (appState.historySessions.isEmpty) {
                return const Center(
                  child: Text(
                    'No history available',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appState.historySessions.length,
                itemBuilder: (context, index) {
                  final session = appState.historySessions[index];
                  // Safe access to first message
                  final title = session.isNotEmpty
                      ? session.first.content.split('\n').first
                      : 'Empty Session';
                  final date = session.isNotEmpty
                      ? session.first.timestamp
                      : DateTime.now();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: const Icon(Icons.history_edu),
                      title: Text(
                        title.length > 50
                            ? '${title.substring(0, 50)}...'
                            : title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        date.toString().substring(0, 16),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: TextButton.icon(
                        icon: const Icon(Icons.restore),
                        label: const Text('Resume'),
                        onPressed: () {
                          appState.loadSession(session);
                        },
                      ),
                      children: session
                          .map((msg) => _buildHistoryMessage(msg))
                          .toList(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryMessage(LogMessage message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: message.role == MessageRole.user
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: message.role == MessageRole.user
              ? Colors.blueAccent.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.role == MessageRole.user ? 'You' : 'Assistant',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            MarkdownBody(data: message.content),
          ],
        ),
      ),
    );
  }
}
