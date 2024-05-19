import 'dart:io';

Future<void> main() async {
  // Define the path to the default debug keystore
  final homeDir =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  final keystorePath = '$homeDir/.android/debug.keystore';
  final alias = 'androiddebugkey';
  final keystorePassword =
      'android'; // The default password for the debug keystore

  // Check if the keystore file exists
  final keystoreFile = File(keystorePath);
  if (!keystoreFile.existsSync()) {
    print('Debug keystore file not found at: $keystorePath');
    return;
  }

  // Construct the keytool command
  final keytoolCommand = [
    '-list',
    '-v',
    '-keystore',
    keystorePath,
    '-alias',
    alias,
    '-storepass',
    keystorePassword,
  ];

  // Run the keytool command
  final result = await Process.run('keytool', keytoolCommand);

  if (result.exitCode != 0) {
    print('Error running keytool: ${result.stderr}');
    return;
  }

  // Process the output to extract SHA-1 and SHA-256 fingerprints
  final output = result.stdout as String;
  final sha1Regex = RegExp(r'SHA1:\s*([0-9A-F:]+)', caseSensitive: false);
  final sha256Regex = RegExp(r'SHA256:\s*([0-9A-F:]+)', caseSensitive: false);

  final sha1Match = sha1Regex.firstMatch(output);
  final sha256Match = sha256Regex.firstMatch(output);

  if (sha1Match != null) {
    final sha1Fingerprint = sha1Match.group(1);
    print('SHA-1 Fingerprint: $sha1Fingerprint');
  } else {
    print('SHA-1 Fingerprint not found.');
  }

  if (sha256Match != null) {
    final sha256Fingerprint = sha256Match.group(1);
    print('SHA-256 Fingerprint: $sha256Fingerprint');
  } else {
    print('SHA-256 Fingerprint not found.');
  }
}
