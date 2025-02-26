import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/models.dart';
import '../database/db_helper.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<List<User>> build() async {
    return _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    final usersData = await DatabaseHelper.instance.fetchAllUsers();
    return usersData.map((map) => User.fromMap(map)).toList();
  }

  Future<void> addUser(User user) async {
    state = const AsyncValue.loading();
    try {
      await DatabaseHelper.instance.insertUser(user.toMap());
      state = AsyncValue.data(await _fetchUsers());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateUser(User user) async {
    state = const AsyncValue.loading();
    try {
      await DatabaseHelper.instance.updateUser(user.userId!, user.toMap());
      state = AsyncValue.data(await _fetchUsers());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteUser(int userId) async {
    state = const AsyncValue.loading();
    try {
      await DatabaseHelper.instance.deleteUser(userId);
      state = AsyncValue.data(await _fetchUsers());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

@riverpod
class CurrentUser extends _$CurrentUser {
  @override
  User? build() => null;

  void setCurrentUser(User? user) {
    state = user;
  }
}
