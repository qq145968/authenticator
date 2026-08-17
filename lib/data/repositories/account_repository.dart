import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';

class AccountRepository {
  static const String _key = 'accounts';
  final SharedPreferences _prefs;

  AccountRepository(this._prefs);

  List<Account> getAllAccounts() {
    final String? jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
    return jsonList
        .map((e) => Account.fromMap(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
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
    final accounts = getAllAccounts();
    final newAccount = account.copyWith(
      id: accounts.isEmpty ? 1 : (accounts.last.id ?? 0) + 1,
      sortOrder: accounts.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    accounts.add(newAccount);
    await _saveAccounts(accounts);
  }

  Future<void> updateAccount(Account account) async {
    final accounts = getAllAccounts();
    final index = accounts.indexWhere((e) => e.id == account.id);
    if (index != -1) {
      accounts[index] = account.copyWith(updatedAt: DateTime.now());
      await _saveAccounts(accounts);
    }
  }

  Future<void> deleteAccount(int id) async {
    final accounts = getAllAccounts();
    accounts.removeWhere((e) => e.id == id);
    await _saveAccounts(accounts);
  }

  Future<void> reorder(List<Account> accounts) async {
    for (int i = 0; i < accounts.length; i++) {
      accounts[i] = accounts[i].copyWith(sortOrder: i);
    }
    await _saveAccounts(accounts);
  }

  Future<void> _saveAccounts(List<Account> accounts) async {
    final jsonList = accounts.map((e) => e.toMap()).toList();
    await _prefs.setString(_key, jsonEncode(jsonList));
  }
}
