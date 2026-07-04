/// Feature-first module layer conventions.
///
/// Each feature module lives under `lib/features/<feature_name>/` and follows
/// Clean Architecture with three layers:
///
/// ```
/// data/
///   datasources/   Remote and local data sources
///   models/        DTOs, serializers, and mappers
///   repositories/  Repository implementations
///
/// domain/
///   entities/      Business entities
///   repositories/  Repository contracts
///   usecases/      Application business rules
///
/// presentation/
///   providers/     Riverpod providers and notifiers
///   screens/       Route-level UI (added per module)
///   widgets/       Feature-specific reusable widgets
/// ```
///
/// Dependency rule: presentation -> domain <- data
abstract final class FeatureLayers {
  static const String dataLayer = 'data';
  static const String domainLayer = 'domain';
  static const String presentationLayer = 'presentation';

  static const List<String> dataSubLayers = [
    'datasources',
    'models',
    'repositories',
  ];

  static const List<String> domainSubLayers = [
    'entities',
    'repositories',
    'usecases',
  ];

  static const List<String> presentationSubLayers = [
    'providers',
    'screens',
    'widgets',
  ];
}
