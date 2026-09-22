class ApiResponse<T> {
  const ApiResponse({required this.data, this.meta, this.message});

  final T data;
  final Map<String, dynamic>? meta;
  final String? message;

  static ApiResponse<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Object? data) parse,
  ) =>
      ApiResponse<T>(
        data: parse(json['data']),
        meta: json['meta'] as Map<String, dynamic>?,
        message: json['message'] as String?,
      );
}

class Paginated<T> {
  const Paginated({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int total;

  bool get hasMore => page * pageSize < total;
}
