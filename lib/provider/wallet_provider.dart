import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  String? _walletAddress;

  String? get walletAddress => _walletAddress;

  void updateAddress(String address) {
    _walletAddress = address;
    notifyListeners();
  }

  void removeAddress() {
    _walletAddress = null;
    notifyListeners();
  }
}
