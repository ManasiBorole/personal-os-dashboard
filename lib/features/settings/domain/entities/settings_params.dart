
/// Parameters for updating a user profile.
final class UpdateUserProfileParams {
  const UpdateUserProfileParams({
    required this.displayName,
    required this.phone,
    required this.bio,
  });

  final String displayName;
  final String? phone;
  final String bio;
}
