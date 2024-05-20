import 'dart:io';

enum SHAType { SHA1, SHA256 }

Future<String> getKeystoreSHA(
  String keystorePath,
  String keyAlias,
  String password,
  SHAType shaType,
) async {
  final result = await Process.run('keytool', [
    '-list',
    '-v',
    '-keystore',
    keystorePath,
    '-alias',
    keyAlias,
    '-storepass',
    password,
  ]);

  if (result.exitCode != 0) {
    throw Exception(
        'Failed to get keystore ${shaType.toString().split('.').last}: ${result.stderr}');
  }

  final output = result.stdout as String;
  final shaRegex =
      RegExp('${shaType.toString().split('.').last}: ([A-F0-9:]+)');
  final match = shaRegex.firstMatch(output);
  if (match == null) {
    throw Exception(
        'Failed to parse keystore ${shaType.toString().split('.').last}');
  }

  return match.group(1)!;
}
