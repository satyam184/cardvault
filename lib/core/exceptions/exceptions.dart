class QuotaExhaustedException implements Exception {
  final String provider;
  final String message;
  const QuotaExhaustedException(this.provider, this.message);

  @override
  String toString() => 'QuotaExhaustedException($provider)';
}

class AllProviderFailedException implements Exception {
  final List<String> errors;
  const AllProviderFailedException(this.errors);

  @override
  String toString() =>
      'AllProvidersFailedException: All AI providers failed.\n${errors.join('\n')}';
}
