import 'package:shared_preferences/shared_preferences.dart';

class WalletSharedPreferences {

  Future<void> saveWalletConnectInitialized(bool isInitialized) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('walletConnectInitialized', isInitialized);
  }

  Future<bool?> getWalletConnectInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('walletConnectInitialized') ?? false;
  }
}