enum AppState {
  dev,
  beta,
  release;

  static AppState fromString(String? s) {
    if (s != null) {
      if (s.toLowerCase() == 'release') {
        return AppState.release;
      } else if (s.toLowerCase() == 'beta') {
        return AppState.beta;
      }
    }

    return AppState.dev;
  }
}
