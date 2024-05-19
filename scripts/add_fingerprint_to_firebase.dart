import 'dart:io';

Future<void> addFingerprintToFirebase(
  String fingerprint,
  String appId,
  String projectID,
) async {
  final command = [
    'apps:android:sha:create',
    appId,
    fingerprint,
    '--project',
    projectID,
  ];

  final result = await Process.run('firebase', command);

  if (result.exitCode != 0) {
    print('Error adding fingerprint to Firebase: ${result.stderr}');
  } else {
    print('Fingerprint added to Firebase successfully.');
  }
}
