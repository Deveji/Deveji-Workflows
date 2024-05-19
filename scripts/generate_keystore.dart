import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() async {
  // Set the necessary fields
  final organizationalUnit = 'Your Organizational Unit';
  final organization = 'Your Organization';
  final locality = 'Your Locality';
  final stateProvince = 'Your State/Province';
  final countryCode = 'Your Country Code';
  final keystorePath = './upload-keystore.jks';
  final keyAlias = 'upload';
  final keySize = '2048';
  final validity = '10000';

  // Generate a random password
  final password = generateRandomPassword(25);

  // Get the name from git
  final firstLastName = await getGitUserName();

  // Generate the keystore
  await generateKeystore(
    keystorePath,
    keyAlias,
    keySize,
    validity,
    password,
    organizationalUnit,
    organization,
    locality,
    stateProvince,
    countryCode,
    firstLastName,
  );

  // Check SHA1 and SHA256 for the generated key
  final sha1 = await getKeystoreSHA1(keystorePath, keyAlias, password);
  final sha256 = await getKeystoreSHA256(keystorePath, keyAlias, password);

  print('Keystore generated successfully!');
  print('Keystore path: $keystorePath');
  print('Key alias: $keyAlias');
  print('Password: $password');
  print('SHA1: $sha1');
  print('SHA256: $sha256');
}

String generateRandomPassword(int length) {
  final random = Random.secure();
  final bytes = List<int>.generate(length, (_) => random.nextInt(256));
  return base64Url.encode(bytes);
}

Future<String> getGitUserName() async {
  final result = await Process.run('git', ['config', '--get', 'user.name']);
  if (result.exitCode != 0) {
    throw Exception('Failed to get git user name: ${result.stderr}');
  }
  return result.stdout.trim();
}

Future<void> generateKeystore(
  String keystorePath,
  String keyAlias,
  String keySize,
  String validity,
  String password,
  String organizationalUnit,
  String organization,
  String locality,
  String stateProvince,
  String countryCode,
  String firstLastName,
) async {
  final dname =
      'CN=$firstLastName, OU=$organizationalUnit, O=$organization, L=$locality, ST=$stateProvince, C=$countryCode';

  final result = await Process.run('keytool', [
    '-genkey',
    '-v',
    '-keystore',
    keystorePath,
    '-storetype',
    'JKS',
    '-keyalg',
    'RSA',
    '-keysize',
    keySize,
    '-validity',
    validity,
    '-alias',
    keyAlias,
    '-keypass',
    password,
    '-storepass',
    password,
    '-dname',
    dname,
  ]);

  if (result.exitCode != 0) {
    throw Exception('Failed to generate keystore: ${result.stderr}');
  }
}

Future<String> getKeystoreSHA1(
  String keystorePath,
  String keyAlias,
  String password,
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
    throw Exception('Failed to get keystore SHA1: ${result.stderr}');
  }

  final output = result.stdout as String;
  final sha1Regex = RegExp(r'SHA1: ([A-F0-9:]+)');
  final match = sha1Regex.firstMatch(output);
  if (match == null) {
    throw Exception('Failed to parse keystore SHA1');
  }

  return match.group(1)!;
}

Future<String> getKeystoreSHA256(
  String keystorePath,
  String keyAlias,
  String password,
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
    throw Exception('Failed to get keystore SHA256: ${result.stderr}');
  }

  final output = result.stdout as String;
  final sha256Regex = RegExp(r'SHA256: ([A-F0-9:]+)');
  final match = sha256Regex.firstMatch(output);
  if (match == null) {
    throw Exception('Failed to parse keystore SHA256');
  }

  return match.group(1)!;
}
