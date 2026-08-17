import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';

class AccountRepository {
  static const String _key = 'accounts';
  final SharedPreferences _prefs;

  AccountRepository(this._prefs);

  List<Account> _allWithDeleted() {
    final String? jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
    return jsonList
        .map((e) => Account.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  List<Account> getAllAccounts() {
    return _allWithDeleted()
        .where((e) => !e.isDeleted)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<Account> getDeletedAccounts() {
    return _allWithDeleted()
        .where((e) => e.isDeleted)
        .toList()
      ..sort((a, b) {
        final aDate = a.deletedAt ?? a.updatedAt;
        final bDate = b.deletedAt ?? b.updatedAt;
        return bDate.compareTo(aDate);
      });
  }

  List<String> getCategories() {
    final accounts = getAllAccounts();
    final categories = accounts.map((e) => e.category).toSet().toList();
    if (!categories.contains('未分类')) {
      categories.insert(0, '未分类');
    }
    return categories;
  }

  List<Account> getByCategory(String category) {
    if (category == '全部') return getAllAccounts();
    return getAllAccounts().where((e) => e.category == category).toList();
  }

  List<Account> search(String query) {
    final accounts = getAllAccounts();
    final lowerQuery = query.toLowerCase();
    return accounts
        .where((e) =>
            e.issuer.toLowerCase().contains(lowerQuery) ||
            e.label.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<void> addAccount(Account account) async {
    final all = _allWithDeleted();
    final newAccount = account.copyWith(
      id: all.isEmpty ? 1 : ((all.map((e) => e.id ?? 0).fold<int>(0, (a, b) => a > b ? a : b)) + 1),
      sortOrder: getAllAccounts().length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      deletedAt: null,
    );
    all.add(newAccount);
    await _saveAll(all);
  }

  Future<void> updateAccount(Account account) async {
    final all = _allWithDeleted();
    final index = all.indexWhere((e) => e.id == account.id);
    if (index != -1) {
      all[index] = account.copyWith(updatedAt: DateTime.now());
      await _saveAll(all);
    }
  }

  /// 软删除：将 isDeleted 设为 true，记录删除时间
  Future<void> softDeleteAccount(int id) async {
    final all = _allWithDeleted();
    final index = all.indexWhere((e) => e.id == id);
    if (index != -1) {
      all[index] = all[index].copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _saveAll(all);
    }
  }

  /// 从回收站恢复账户
  Future<void> restoreAccount(int id) async {
    final all = _allWithDeleted();
    final index = all.indexWhere((e) => e.id == id);
    if (index != -1) {
      all[index] = all[index].copyWith(
        isDeleted: false,
        deletedAt: null,
        updatedAt: DateTime.now(),
      );
      await _saveAll(all);
    }
  }

  /// 彻底删除（回收站中永久清除）
  Future<void> permanentDeleteAccount(int id) async {
    final all = _allWithDeleted();
    all.removeWhere((e) => e.id == id);
    await _saveAll(all);
  }

  /// 清空回收站
  Future<void> clearTrash() async {
    final all = _allWithDeleted().where((e) => !e.isDeleted).toList();
    await _saveAll(all);
  }

  @Deprecated('Use softDeleteAccount instead')
  Future<void> deleteAccount(int id) => softDeleteAccount(id);

  Future<void> reorder(List<Account> accounts) async {
    final all = _allWithDeleted();
    for (int i = 0; i < accounts.length; i++) {
      final idx = all.indexWhere((e) => e.id == accounts[i].id);
      if (idx != -1) {
        all[idx] = all[idx].copyWith(sortOrder: i, updatedAt: DateTime.now());
      }
    }
    await _saveAll(all);
  }

  Future<void> _saveAll(List<Account> accounts) async {
    final jsonList = accounts.map((e) => e.toMap()).toList();
    await _prefs.setString(_key, jsonEncode(jsonList));
  }

  @Deprecated('Use _saveAll instead')
  Future<void> _saveAccounts(List<Account> accounts) => _saveAll(accounts);
}
