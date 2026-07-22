import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:flutter_architect/src/commands/init_command.dart';
import 'package:flutter_architect/src/commands/create_command.dart';
import 'package:flutter_architect/src/commands/cicd_command.dart';

Future<void> main(List<String> arguments) async {
  final runner = CommandRunner<void>(
    'flutter_architect',
    'Scaffold production-ready Clean Architecture Flutter projects.',
  )
    ..addCommand(InitCommand())
    ..addCommand(CreateCommand())
    ..addCommand(CicdCommand());

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(e.usage);
    exit(64);
  } catch (e) {
    stderr.writeln(e);
    exit(1);
  }
}
