enum FilterSort {
  alphabeticalAsc,
  alphabeticalDesc,
}

class FilterSelection {
  final String category;
  final FilterSort sort;

  const FilterSelection({
    required this.category,
    required this.sort,
  });
}
