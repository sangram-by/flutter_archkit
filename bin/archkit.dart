import 'package:flutter_archkit/src/cli/command_runner.dart';

Future<void> main(List<String> rawArguments) async {
  final arguments = List<String>.from(rawArguments);
  if (arguments.isNotEmpty) {
    final first = arguments[0];
    if (first == '-f' || first == '--feature') {
      arguments[0] = 'feature';
    } else if (first == '-c' || first == '--create') {
      arguments[0] = 'create';
    } else if (first == '-r' || first == '--route') {
      arguments[0] = 'route';
    } else if (first == '-n' || first == '--network') {
      arguments[0] = 'network';
    } else if (first == '-g' || first == '-gen' || first == '--generate') {
      arguments[0] = 'generate';
    } else if (first == '-s' || first == '--storage') {
      arguments[0] = 'storage';
    } else if (first == '-fl' || first == '--flavor') {
      arguments[0] = 'flavor';
    }
  }

  await FlutterArchkitCommandRunner().run(arguments);
}
