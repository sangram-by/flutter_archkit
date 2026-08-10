import 'package:args/command_runner.dart';
import 'package:flutter_archkit/src/cli/commands/create_command.dart';
import 'package:flutter_archkit/src/cli/commands/create_feature_command.dart';
import 'package:flutter_archkit/src/cli/commands/generate_command.dart';
import 'package:flutter_archkit/src/cli/commands/network_command.dart';
import 'package:flutter_archkit/src/cli/commands/route_command.dart';

class FlutterArchkitCommandRunner extends CommandRunner<int> {
  FlutterArchkitCommandRunner()
      : super('flutter_archkit', 'Flutter Architecture Generator') {
    addCommand(CreateCommand());
    addCommand(CreateFeatureCommand());
    addCommand(RouteCommand());
    addCommand(NetworkCommand());
    addCommand(GenerateCommand());
  }
}
