import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';
import 'message.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;

  String _selectedProvider = 'Groq';
  String _selectedModel = AppConstants.defaultModel;
  String _apiKey = '';
  bool _isLoading = false;
  ThemeMode _themeMode = ThemeMode.system;

  final List<LogMessage> _messages = [];
  List<List<LogMessage>> _historySessions = [];
  List<String> _savedCommands = [];

  AppState(this.prefs) {
    _loadSettings();
    _loadHistory();
  }

  String get selectedProvider => _selectedProvider;
  String get selectedModel => _selectedModel;
  String get apiKey => _apiKey;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;
  List<LogMessage> get messages => List.unmodifiable(_messages);
  List<List<LogMessage>> get historySessions =>
      List.unmodifiable(_historySessions);
  List<String> get savedCommands => List.unmodifiable(_savedCommands);

  void _loadSettings() {
    _selectedProvider = prefs.getString('provider') ?? 'Groq';
    _selectedModel = prefs.getString('model') ?? AppConstants.defaultModel;
    _apiKey = prefs.getString('apiKey_$_selectedProvider') ?? '';
    final themeIndex =
        prefs.getInt('theme_mode') ?? 0; // 0: system, 1: light, 2: dark
    _themeMode = ThemeMode.values[themeIndex];
    _savedCommands = prefs.getStringList('saved_commands') ?? [];
    notifyListeners();
  }

  Future<void> _loadHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/chat_history.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _historySessions = jsonList.map((session) {
          return (session as List).map((m) => LogMessage.fromJson(m)).toList();
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/chat_history.json');
      final jsonList = _historySessions.map((session) {
        return session.map((m) => m.toJson()).toList();
      }).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> setProvider(String provider) async {
    _selectedProvider = provider;
    _selectedModel = AppConstants.providerModels[provider]?.first ?? '';
    _apiKey = prefs.getString('apiKey_$provider') ?? '';
    await prefs.setString('provider', provider);
    await prefs.setString('model', _selectedModel);
    notifyListeners();
  }

  Future<void> setModel(String model) async {
    _selectedModel = model;
    await prefs.setString('model', model);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await prefs.setString('apiKey_$_selectedProvider', key);
    notifyListeners();
  }

  void addMessage(LogMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearMessages() {
    if (_messages.isNotEmpty) {
      _historySessions.insert(0, List.from(_messages));
      _saveHistory(); // Async save
      _messages.clear();
      notifyListeners();
    }
  }

  // Navigation & Interaction State
  int _selectedIndex = 0;
  String? _pendingInput;

  int get selectedIndex => _selectedIndex;
  String? get pendingInput => _pendingInput;

  void setTabIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setPendingInput(String text) {
    _pendingInput = text;
    notifyListeners();
  }

  String? consumePendingInput() {
    final input = _pendingInput;
    _pendingInput = null;
    // No notifyListeners needed here as we want to just consume it silently usually,
    // but if UI depends on it, we might need it. For now, let's keep it simple.
    return input;
  }

  void loadSession(List<LogMessage> session) {
    // Save current session first if not empty (optional, but good practice)
    // clearMessages already saves, so we can use that, BUT clearMessages clears the list.
    // We want to replace the list.

    if (_messages.isNotEmpty) {
      _historySessions.insert(0, List.from(_messages));
      _saveHistory();
    }

    _messages.clear();
    _messages.addAll(session);

    // Switch to chat
    _selectedIndex = 0;
    notifyListeners();
  }

  // Saved Commands Logic
  Future<void> toggleSavedCommand(String command) async {
    if (_savedCommands.contains(command)) {
      _savedCommands.remove(command);
    } else {
      _savedCommands.add(command);
    }
    await prefs.setStringList('saved_commands', _savedCommands);
    notifyListeners();
  }

  bool isCommandSaved(String command) {
    return _savedCommands.contains(command);
  }
}
