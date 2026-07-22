enum StateManagement { bloc, riverpod, provider, getx, none }
enum RouterType { goRouter, autoRoute, navigator2, vanilla }
enum NetworkingType { rest, graphQL, both, none }
enum ArchitectureType { clean, mvvm }
enum CicdProvider { githubActions, codemagic, both, none }

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
    required this.useLocalization,
    required this.locales,
    required this.useFlavors,
    required this.cicd,
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
  final bool useLocalization;
  final List<String> locales;
  final bool useFlavors;
  final CicdProvider cicd;

  /// Sensible defaults for `--no-interaction` and automated tests.
  factory SetupConfig.defaults({required String projectName}) {
    return SetupConfig(
      architecture: ArchitectureType.clean,
      projectName: projectName,
      stateManagement: StateManagement.bloc,
      router: RouterType.goRouter,
      networking: NetworkingType.rest,
      useFirebase: false,
      useHive: true,
      useGetIt: true,
      useFreezed: false,
      useEquatable: true,
      generateAuth: true,
      generateSample: false,
      useLocalization: true,
      locales: const ['en', 'ar'],
      useFlavors: true,
      cicd: CicdProvider.githubActions,
    );
  }
}
