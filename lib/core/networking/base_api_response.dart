class BaseApiResponse<T> {
  BaseApiResponse({required this.data});

  late final T data;

  BaseApiResponse.fromJson(
    json,
    Map<Type, dynamic> decoders, {
    required Type type,
  }) {
    assert(
      decoders.containsKey(type),
      'Your config/decoders.dart file does not contain a decoder for the following class: ${type.toString()} in modelDecoders',
    );
    data = decoders[type]!(json) as T;
  }
}
