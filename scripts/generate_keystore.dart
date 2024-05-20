import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'get_keystore_hash.dart';

void main() async {
  // Set the necessary fields
  final organizationalUnit = 'Deveji';
  final organization = 'Deveji';
  final locality = 'Warsaw';
  final stateProvince = 'Masovian';
  final countryCode = 'PL';
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
  final sha1 =
      await getKeystoreSHA(keystorePath, keyAlias, password, SHAType.SHA1);
  final sha256 =
      await getKeystoreSHA(keystorePath, keyAlias, password, SHAType.SHA256);

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
