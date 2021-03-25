import 'package:args/command_runner.dart';

import 'package:fvm/constants.dart';
import 'package:fvm/fvm.dart';
import 'package:fvm/src/flutter_tools/flutter_tools.dart';

import 'package:fvm/src/services/cache_service.dart';
import 'package:fvm/src/utils/ask_versions.dart';
import 'package:fvm/src/utils/pubdev.dart';

import 'package:fvm/src/workflows/use_version.workflow.dart';
import 'package:io/io.dart';

/// Use an installed SDK version
class UseCommand extends Command<int> {
  @override
  final name = 'use';

  @override
  final description = 'Which Flutter SDK Version you would like to use';

  /// Constructor
  UseCommand() {
    argParser
      ..addFlag(
        'global',
        help:
            'Sets version as the global version.\nMake sure Flutter PATH env is set to: $kDefaultFlutterPath',
        negatable: false,
      )
      ..addFlag(
        'force',
        help: 'Skips command guards that does Flutter project checks.',
        negatable: false,
      );
  }
  @override
  Future<int> run() async {
    String version;

    // If no version is provider show selection
    if (argResults.rest.isEmpty) {
      final cacheVersions = await CacheService.getAll();
      if (cacheVersions.isEmpty) {
        throw Exception('Please install a version. fvm install <version>');
      }

      /// Ask which version to select
      version = askWhichVersion(cacheVersions);
    }

    version ??= argResults.rest[0];

    final global = argResults['global'] == true;
    final force = argResults['force'] == true;

    // Get valid flutter version
    final validVersion = await FlutterTools.inferVersion(version);

    /// Run use workflow
    await useVersionWorkflow(validVersion, global: global, force: force);

    // Check if its running the latest version of FVM
    await checkIfLatestVersion();

    return ExitCode.success.code;
  }
}
