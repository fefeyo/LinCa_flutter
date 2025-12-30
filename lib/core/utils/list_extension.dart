extension ListExtension<T> on List<T> {
  List<List<T>> chunk(int size) {
    final List<List<T>> chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(
        sublist(
          i,
          (i + size > length) ? length : i + size,
        ),
      );
    }
    return chunks;
  }
}
