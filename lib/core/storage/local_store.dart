abstract interface class LocalStore {
  Future<void> init();
  Future<void> close();

  Future<T?> read<T>(String box, String key);
  Future<void> write<T>(String box, String key, T value);
  Future<void> delete(String box, String key);

  Future<List<T>> readAll<T>(String box);
  Future<void> putAll<T>(String box, Map<String, T> entries);
  Future<void> clearBox(String box);

  Future<void> wipe();
  Future<DateTime?> lastUpdated(String box);
}
