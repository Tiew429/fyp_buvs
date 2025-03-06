import 'package:blockchain_university_voting_system/blockchain/smart_contract_service.dart';
import 'package:blockchain_university_voting_system/blockchain/wallet_connect_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletConnectInitializer extends StatefulWidget {
  final Widget child;

  const WalletConnectInitializer({
    super.key, 
    required this.child,
  });

  @override
  State<WalletConnectInitializer> createState() => _WalletConnectInitializerState();
}

class _WalletConnectInitializerState extends State<WalletConnectInitializer> {
  late final WalletConnectService _walletConnectService;
  late final SmartContractService _smartContractService;
  bool _isInitializing = true;
  String _statusMessage = "正在初始化区块链连接...";
  bool _hasError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _setupWalletService();
      await _setupSmartContract();
      
      // 添加额外的延迟，确保一切都已准备就绪
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint("Error during initialization: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _setupWalletService() async {
    if (mounted) {
      setState(() {
        _statusMessage = "正在连接钱包服务...";
      });
    }
    
    debugPrint("WalletConnectInitializer: Setting up wallet service.");
    _walletConnectService = Provider.of<WalletConnectService>(context, listen: false);
    await _walletConnectService.initialize(context);
  }

  Future<void> _setupSmartContract() async {
    if (mounted) {
      setState(() {
        _statusMessage = "正在连接智能合约...";
      });
    }
    
    debugPrint("WalletConnectInitializer: Setting up smart contract.");
    _smartContractService = Provider.of<SmartContractService>(context, listen: false);
    await _smartContractService.initialize();
  }

  @override
  void dispose() {
    _walletConnectService.unsubscribeFromEvents();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildLoadingScreen();
    } else if (_hasError) {
      return _buildErrorScreen();
    } else {
      return widget.child;
    }
  }

  Widget _buildLoadingScreen() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 20),
              Text(
                "初始化失败",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _hasError = false;
                    _errorMessage = "";
                  });
                  _initializeServices();
                },
                child: const Text("重试"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
