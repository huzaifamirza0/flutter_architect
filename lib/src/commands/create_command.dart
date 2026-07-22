import 'package:args/command_runner.dart';
import 'create/feature_creator.dart';
import 'create/model_creator.dart';
import 'create/entity_creator.dart';
import 'create/repository_creator.dart';
import 'create/usecase_creator.dart';
import 'create/viewmodel_creator.dart';
import 'create/screen_creator.dart';
import 'create/widget_creator.dart';
import 'create/datasource_creator.dart';

class CreateCommand extends Command<void> {
  @override
  final String name = 'create';

  @override
  final String description =
      'Generate a feature, screen, widget, model, entity, repository, usecase, datasource, or viewmodel.';

  @override
  String get invocation => 'flutter_architect create <type> <Name>';

  CreateCommand() {
    addSubcommand(FeatureCreatorCommand());
    addSubcommand(ScreenCreatorCommand());
    addSubcommand(WidgetCreatorCommand());
    addSubcommand(DatasourceCreatorCommand());
    addSubcommand(ModelCreatorCommand());
    addSubcommand(EntityCreatorCommand());
    addSubcommand(RepositoryCreatorCommand());
    addSubcommand(UsecaseCreatorCommand());
    addSubcommand(ViewModelCreatorCommand());
  }

  @override
  void run() {
    printUsage();
  }
}
