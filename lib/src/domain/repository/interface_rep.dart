abstract class RepositoryInterface<T> {
  Future<int> create(T entity);
  Future<List<T>> findAll();
  Future<List<T>> findById(int id);
  Future<void> delet(int id);
}
