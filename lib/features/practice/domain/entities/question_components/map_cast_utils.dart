Map<String, dynamic> safeMapCast(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  } else if (data is Map) {
    final Map<String, dynamic> result = {};
    data.forEach((key, value) {
      if (key is String) {
        result[key] = value;
      }
    });
    return result;
  }
  return {};
}
