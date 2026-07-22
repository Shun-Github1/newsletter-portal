class ApiResponse<T> {
  final int code;
  final String msg;
  final T? data;

  const ApiResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return ApiResponse<T>(
      code: json['code'] as int,
      msg: json['msg'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'code': code,
      'msg': msg,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }
}
