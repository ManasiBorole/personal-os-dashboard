sealed class ContactFormState {
  const ContactFormState();
}

final class ContactFormIdle extends ContactFormState {
  const ContactFormIdle();
}

final class ContactFormLoading extends ContactFormState {
  const ContactFormLoading();
}

final class ContactFormSuccess extends ContactFormState {
  const ContactFormSuccess({this.message});
  final String? message;
}

final class ContactFormError extends ContactFormState {
  const ContactFormError(this.message);
  final String message;
}

extension ContactFormStateX on ContactFormState {
  bool get isLoading => this is ContactFormLoading;
}

sealed class CompanyFormState {
  const CompanyFormState();
}

final class CompanyFormIdle extends CompanyFormState {
  const CompanyFormIdle();
}

final class CompanyFormLoading extends CompanyFormState {
  const CompanyFormLoading();
}

final class CompanyFormSuccess extends CompanyFormState {
  const CompanyFormSuccess({this.message});
  final String? message;
}

final class CompanyFormError extends CompanyFormState {
  const CompanyFormError(this.message);
  final String message;
}

extension CompanyFormStateX on CompanyFormState {
  bool get isLoading => this is CompanyFormLoading;
}
