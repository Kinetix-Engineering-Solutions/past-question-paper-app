final class PagedResponse<T> {
  PagedResponse({
    required Iterable<T> items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  }) : items = List.unmodifiable(items);

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  bool get hasNextPage => page < totalPages;

  factory PagedResponse.fromJson(
    Map<String, Object?> json,
    T Function(Map<String, Object?> json) itemFromJson,
  ) {
    if (json case {
      'items': final List items,
      'page': final int page,
      'pageSize': final int pageSize,
      'totalCount': final int totalCount,
      'totalPages': final int totalPages,
    }) {
      if (page < 1 || pageSize < 1 || totalCount < 0 || totalPages < 0) {
        throw const FormatException('Invalid paged response.');
      }

      final parsedItems = <T>[];

      for (final item in items) {
        if (item is! Map) {
          throw const FormatException('Invalid paged response item.');
        }

        parsedItems.add(itemFromJson(Map<String, Object?>.from(item)));
      }

      return PagedResponse(
        items: parsedItems,
        page: page,
        pageSize: pageSize,
        totalCount: totalCount,
        totalPages: totalPages,
      );
    }

    throw const FormatException('Invalid paged response.');
  }
}
