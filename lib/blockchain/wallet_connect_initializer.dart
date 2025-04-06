import 'package:blockchain_university_voting_system/blockchain/smart_contract_service.dart';
import 'package:blockchain_university_voting_system/blockchain/wallet_connect_service.dart';
import 'package:blockchain_university_voting_system/database/wallet_shared_preferences.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
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
  WalletConnectService? _walletConnectService;
  SmartContractService? _smartContractService;
  WalletSharedPreferences walletSharedPreferences = WalletSharedPreferences();
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
      debugPrint("WalletConnectInitializer: Starting services initialization");
      
      // 在每次初始化前，先尝试重置服务
      try {
        debugPrint("WalletConnectInitializer: Trying to reset services before initialization");
        WalletConnectService.reset();
        SmartContractService.reset();
      } catch (e) {
        debugPrint("WalletConnectInitializer: Error during service reset: $e");
        // 继续初始化，不中断流程
      }
      
      bool isInitialized = await walletSharedPreferences.getWalletConnectInitialized() ?? false;

      // 无论之前是否初始化，都尝试重新初始化
      // 这样可以确保每次启动应用时都能正确连接区块链
      if (mounted) {
        setState(() {
          _statusMessage = "正在连接钱包服务...";
        });
      }
      
      debugPrint("WalletConnectInitializer: Setting up wallet service");
      
      // 确保字段为空，避免重复初始化
      _walletConnectService = null;
      
      // 获取新的服务实例
      _walletConnectService = Provider.of<WalletConnectService>(rootNavigatorKey.currentContext!, listen: false);
      
      try {
        await _walletConnectService!.initialize(context);
        debugPrint("WalletConnectInitializer: Wallet service initialized successfully");
      } catch (e) {
        debugPrint("WalletConnectInitializer: Failed to initialize wallet service: $e");
        throw Exception("钱包服务初始化失败: $e");
      }

      if (mounted) {
        setState(() {
          _statusMessage = "正在连接智能合约...";
        });
      }
      
      debugPrint("WalletConnectInitializer: Setting up smart contract");
      
      // 确保字段为空，避免重复初始化
      _smartContractService = null;
      
      // 获取新的服务实例
      _smartContractService = Provider.of<SmartContractService>(rootNavigatorKey.currentContext!, listen: false);
      
      try {
        await _smartContractService!.initialize(context);
        debugPrint("WalletConnectInitializer: Smart contract initialized successfully");
      } catch (e) {
        debugPrint("WalletConnectInitializer: Failed to initialize smart contract: $e");
        throw Exception("智能合约初始化失败: $e");
      }
      
      // 保存初始化状态
      await walletSharedPreferences.saveWalletConnectInitialized(true);
      
      if (mounted) {
        setState(() {
          _statusMessage = "初始化完成，正在跳转...";
          _isInitializing = false;
        });
      }
      
      debugPrint("WalletConnectInitializer: Services initialization completed");
    } catch (e) {
      debugPrint("WalletConnectInitializer: Error during initialization: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    debugPrint("WalletConnectInitializer: Disposing");
    
    // 当应用重启时，我们不希望立即重置服务
    // 所以只保存状态，不主动重置
    walletSharedPreferences.saveWalletConnectInitialized(false);
    
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
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 应用图标
              Icon(
                Icons.how_to_vote, // 或者使用其他适合您应用的图标
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 40),
              // 进度指示器
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
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
