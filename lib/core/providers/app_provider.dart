import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/account.dart';
import '../../data/models/user.dart';
import '../../data/repositories/account_repository.dart';
import '../utils/totp_utils.dart';

class AppProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  late final AccountRepository _accountRepo;

  bool _isOnboardingComplete = false;
  bool _privacyAccepted = false;
  bool _isLoggedIn = false;
  UserInfo? _user;
  bool _isDarkMode = false;
  List<Account> _accounts = [];
  List<Account> _deletedAccounts = [];
  String _selectedCategory = '全部';

  AppProvider(this._prefs) {
    _accountRepo = AccountRepository(_prefs);
    _isOnboardingComplete = _prefs.getBool('onboarding_complete') ?? false;
    _privacyAccepted = _prefs.getBool('privacy_accepted') ?? false;
    _isLoggedIn = _prefs.getBool('logged_in') ?? false;
    _isDarkMode = _prefs.getBool('dark_mode') ?? false;
    _loadUser();
    _loadAccounts();
  }

  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get privacyAccepted => _privacyAccepted;
  bool get isLoggedIn => _isLoggedIn;
  UserInfo? get user => _user;
  bool get isDarkMode => _isDarkMode;
  List<Account> get accounts => _accounts;
  List<Account> get deletedAccounts => _deletedAccounts;
  String get selectedCategory => _selectedCategory;
  bool get hasDeletedAccounts => _deletedAccounts.isNotEmpty;

  List<Account> get filteredAccounts {
    if (_selectedCategory == '全部') return _accounts;
    return _accounts.where((e) => e.category == _selectedCategory).toList();
  }

  List<String> get categories {
    final cats = _accounts.map((e) => e.category).toSet().toList();
    final all = ['全部', ...cats];
    if (!all.contains('未分类') && _accounts.isNotEmpty) {
      all.insert(1, '未分类');
    }
    return all;
  }

  void _loadUser() {
    final userStr = _prefs.getString('user_info');
    if (userStr != null) {
      try {
        final map = jsonDecode(userStr) as Map<String, dynamic>;
        _user = UserInfo.fromMap(map);
      } catch (_) {
        _user = null;
      }
    }
  }

  void _loadAccounts() {
    _accounts = _accountRepo.getAllAccounts();
    _deletedAccounts = _accountRepo.getDeletedAccounts();
    notifyListeners();
  }

  Future<void> acceptPrivacy() async {
    _privacyAccepted = true;
    await _prefs.setBool('privacy_accepted', true);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true;
    await _prefs.setBool('onboarding_complete', true);
    notifyListeners();
  }

  Future<void> login(String username) async {
    _isLoggedIn = true;
    _user = UserInfo(
      userId: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      avatar: '',
    );
    await _prefs.setBool('logged_in', true);
    await _prefs.setString('user_info', jsonEncode(_user!.toMap()));
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _user = null;
    await _prefs.setBool('logged_in', false);
    await _prefs.remove('user_info');
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    await _accountRepo.addAccount(account);
    _loadAccounts();
  }

  Future<void> softDeleteAccount(int id) async {
    await _accountRepo.softDeleteAccount(id);
    _loadAccounts();
  }

  Future<void> restoreAccount(int id) async {
    await _accountRepo.restoreAccount(id);
    _loadAccounts();
  }

  Future<void> permanentDeleteAccount(int id) async {
    await _accountRepo.permanentDeleteAccount(id);
    _loadAccounts();
  }

  Future<void> clearTrash() async {
    await _accountRepo.clearTrash();
    _loadAccounts();
  }

  @Deprecated('Use softDeleteAccount instead')
  Future<void> deleteAccount(int id) => softDeleteAccount(id);

  Future<void> updateAccount(Account account) async {
    await _accountRepo.updateAccount(account);
    _loadAccounts();
  }

  TotpResult? getTotp(Account account) {
    try {
      return TotpUtils.generateTotp(account.secret, period: account.period, digits: account.digits);
    } catch (_) {
      return null;
    }
  }

  List<Account> searchAccounts(String query) {
    if (query.isEmpty) return _accounts;
    return _accountRepo.search(query);
  }
}
