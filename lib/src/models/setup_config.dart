enum StateManagement { bloc, riverpod, provider, getx, none }
enum RouterType { goRouter, autoRoute, navigator2, vanilla }
enum NetworkingType { rest, graphQL, both, none }
enum ArchitectureType { clean, mvvm }

class SetupConfig {
  SetupConfig({
    required this.architecture,
    required this.projectName,
    required this.stateManagement,
    required this.router,
    required this.networking,
    required this.useFirebase,
    required this.useHive,
    required this.useGetIt,
    required this.useFreezed,
    required this.useEquatable,
    required this.generateAuth,
    required this.generateSample,
  });

  final ArchitectureType architecture;
  final String projectName;
  final StateManagement stateManagement;
  final RouterType router;
  final NetworkingType networking;
  final bool useFirebase;
  final bool useHive;
  final bool useGetIt;
  final bool useFreezed;
  final bool useEquatable;
  final bool generateAuth;
  final bool generateSample;
}
