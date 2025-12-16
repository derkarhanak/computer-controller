import 'dart:io';

class ExecutionResult {
  final String stdout;
  final String stderr;
  final int exitCode;

  ExecutionResult(this.stdout, this.stderr, this.exitCode);

  bool get isSuccess => exitCode == 0;
}

class PythonExecutor {
  Future<ExecutionResult> executeScript(String code) async {
    try {
      // Create a temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/temp_script_${DateTime.now().millisecondsSinceEpoch}.py',
      );

      await tempFile.writeAsString(code);

      // Execute the script
      final result = await Process.run('python3', [tempFile.path]);

      // Clean up
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      return ExecutionResult(
        result.stdout.toString(),
        result.stderr.toString(),
        result.exitCode,
      );
    } catch (e) {
      return ExecutionResult('', 'Internal Error: $e', -1);
    }
  }
}
