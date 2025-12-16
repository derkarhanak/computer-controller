import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'saved_commands_screen.dart';
import 'settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Removed local _selectedIndex

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: colorScheme.surfaceContainer, // Dynamic sidebar color
            child: Column(
              children: [
                const SizedBox(height: 40), // Window control spacing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.computer, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Controller',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        appState.clearMessages();
                        appState.setTabIndex(
                          0,
                        ); // Ensure we are on the Home tab
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Chat'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 24),
                _buildSidebarItem(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat & Control',
                  index: 0,
                  colorScheme: colorScheme,
                  appState: appState,
                ),
                _buildSidebarItem(
                  icon: Icons.history,
                  label: 'History',
                  index: 1,
                  colorScheme: colorScheme,
                  appState: appState,
                ),
                _buildSidebarItem(
                  icon: Icons.star_outline,
                  label: 'Saved Commands',
                  index: 2,
                  colorScheme: colorScheme,
                  appState: appState,
                ),
                const Spacer(),
                _buildSidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  index: 3,
                  colorScheme: colorScheme,
                  appState: appState,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
          // Main Content Area
          Expanded(
            child: IndexedStack(
              index: appState.selectedIndex,
              children: [
                const HomeScreen(),
                const HistoryScreen(),
                const SavedCommandsScreen(),
                const SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
    required ColorScheme colorScheme,
    required AppState appState,
  }) {
    final isSelected = appState.selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          appState.setTabIndex(index);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blueAccent.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.blueAccent
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
