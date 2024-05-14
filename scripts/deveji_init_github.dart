import 'dart:io';

/// script to initialize a new project on GitHub
/// requires the Git & GitHub CLI(gh)

/// Github team/organization name
const githubTeam = 'Deveji';

/// Initialize a new project on GitHub.
void main() {
  // Initialize Git repository
  Process.run('git', ['init']).then((result) {
    if (result.exitCode != 0) {
      print('Failed to initialize Git repository: ${result.stderr}');
      return; // Exit the script
    }
    print('Git repository initialized.');
  });

  // Add all files to Git
  Process.run('git', ['add', '.']).then((result) {
    if (result.exitCode != 0) {
      print('Failed to add files to Git: ${result.stderr}');
      return; // Exit the script
    }

    print('All files added to Git.');
  });

  // Commit changes
  Process.run('git', ['commit', '-m', 'Initial commit']).then((result) {
    if (result.exitCode != 0) {
      print('Failed to create initial commit: ${result.stderr}');
      return; // Exit the script
    }

    print('Initial commit created.');
  });

  // get current directory name
  final currentDirectory = Directory.current.path.split(Platform.pathSeparator);

  // Create a new repository on GitHub using the GitHub CLI
  Process.run('gh', [
    'repo',
    'create',
    '$githubTeam/${currentDirectory.last}',
    '--private',
    '--source=.',
    '--push'
  ]).then((result) {
    if (result.exitCode != 0) {
      print('Failed to create a new repository on GitHub: ${result.stderr}');
      return; // Exit the script
    }

    print('New repository created on GitHub.');
  });
}
