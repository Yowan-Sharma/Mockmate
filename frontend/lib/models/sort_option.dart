enum SortOption {
  relevance,
  ascending,
  descending,
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.ascending:
        return 'A-Z';
      case SortOption.descending:
        return 'Z-A';
    }
  }
}
