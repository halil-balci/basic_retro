enum RetroPhase {
  editing('Editing', 'Herkesin input girişi yaptığı aşama'),
  grouping('Grouping', 'Inputların gruplandığı aşama'),
  voting('Voting', 'Grupların oylandığı aşama'),
  discuss('Discuss', 'Grupların tartışıldığı aşama');

  const RetroPhase(this.displayName, this.description);

  final String displayName;
  final String description;

  static RetroPhase fromString(String value) {
    return RetroPhase.values.firstWhere(
      (phase) => phase.name == value,
      orElse: () => RetroPhase.editing,
    );
  }
}
