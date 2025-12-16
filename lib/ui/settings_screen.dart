import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF333333))),
          ),
          child: Row(
            children: [
              Text(
                'Settings',
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
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionHeader('Appearance'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<ThemeMode>(
                        value: appState.themeMode,
                        decoration: const InputDecoration(labelText: 'Theme'),
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System (Auto)'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appState.setThemeMode(value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('AI Provider'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: appState.selectedProvider,
                            decoration: const InputDecoration(
                              labelText: 'Provider',
                            ),
                            items: AppConstants.supportedProviders.map((p) {
                              return DropdownMenuItem(value: p, child: Text(p));
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                appState.setProvider(value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: appState.selectedModel,
                            decoration: const InputDecoration(
                              labelText: 'Model',
                            ),
                            items:
                                (AppConstants.providerModels[appState
                                            .selectedProvider] ??
                                        [])
                                    .map((m) {
                                      return DropdownMenuItem(
                                        value: m,
                                        child: Text(m),
                                      );
                                    })
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                appState.setModel(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('API Key'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: appState.apiKey,
                        decoration: InputDecoration(
                          labelText: '${appState.selectedProvider} API Key',
                          hintText: 'sk-...',
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onChanged: (value) {
                          appState.setApiKey(value);
                        },
                      ),
                    ),
                  ),
                  if (appState.selectedProvider == 'Ollama')
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Ollama does not require an API key if running locally on default port 11434.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
