import 'package:equatable/equatable.dart';

/// Base class for domain entities with value-based equality.
abstract base class Entity extends Equatable {
  const Entity();

  @override
  bool get stringify => true;
}
