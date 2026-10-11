import 'dart:io';

Future<bool> localFileExists(String path) => File(path).exists();

bool localFileExistsSync(String path) => File(path).existsSync();

/// Reveals [path] in the OS file manager when supported (desktop).
/// Returns false on platforms where this is not available (mobile/web).
Future<bool> revealLocalFileInExplorer(String path) async {
  final file = File(path);
  if (!await file.exists()) return false;

  try {
    if (Platform.isWindows) {
      // explorer.exe often returns a non-zero exit code even on success.
      await Process.start('explorer.exe', ['/select,', file.path]);
      return true;
    }
    if (Platform.isMacOS) {
      final result = await Process.run('open', ['-R', file.path]);
      return result.exitCode == 0;
    }
    if (Platform.isLinux) {
      final result = await Process.run('xdg-open', [file.parent.path]);
      return result.exitCode == 0;
    }
  } catch (_) {
    return false;
  }
  return false;
}

/// Opens [path] with the OS default application (e.g. system video player).
Future<bool> openLocalFileExternally(String path) async {
  final file = File(path);
  if (!await file.exists()) return false;

  try {
    if (Platform.isWindows) {
      await Process.start(
        'cmd',
        ['/c', 'start', '', file.path],
        runInShell: false,
      );
      return true;
    }
    if (Platform.isMacOS) {
      final result = await Process.run('open', [file.path]);
      return result.exitCode == 0;
    }
    if (Platform.isLinux) {
      final result = await Process.run('xdg-open', [file.path]);
      return result.exitCode == 0;
    }
  } catch (_) {
    return false;
  }
  return false;
}

bool get canRevealLocalFileInExplorer =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

bool get canOpenLocalFileExternally =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

String? localFileParentPath(String path) {
  try {
    return File(path).parent.path;
  } catch (_) {
    return null;
  }
}
