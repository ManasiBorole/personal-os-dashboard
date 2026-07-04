/// Application environment identifiers.
enum AppEnvironment {
  dev,
  staging,
  prod;

  bool get isDev => this == AppEnvironment.dev;

  bool get isStaging => this == AppEnvironment.staging;

  bool get isProd => this == AppEnvironment.prod;

  static AppEnvironment fromString(String value) {
    return AppEnvironment.values.firstWhere(
      (environment) => environment.name == value,
      orElse: () => AppEnvironment.dev,
    );
  }
}
