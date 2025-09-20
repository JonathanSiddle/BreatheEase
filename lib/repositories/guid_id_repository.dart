class GuidRepository {
  GuidRepository({required String Function() guidProvider})
      : _guidProvider = guidProvider;

  final String Function() _guidProvider;
  String get guid => _guidProvider();
}
