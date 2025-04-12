import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:blockchain_university_voting_system/services/auth_service.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'dart:async';

class WalletConnectService {
  ReownAppKitModal? _appkitModal;
  AuthService authService = AuthService();
  bool isInitialized = false;
  bool _isInitializing = false;
  static BuildContext? _lastContext;

  // 使用单例模式，但允许重置实例
  static WalletConnectService? _instance;
  
  factory WalletConnectService() {
    _instance ??= WalletConnectService._internal();
    return _instance!;
  }
  
  // 重置方法，用于应用重启时清理实例
  static void reset() {
    if (_instance != null) {
      _instance!._reset();
      _instance = null;
    }
  }
  
  void _reset() {
    try {
      // 尝试清理现有资源
      if (_appkitModal != null) {
        debugPrint("WalletConnectService: Unsubscribing events before reset");
        unsubscribeFromEvents();
        _appkitModal = null;
      }
      isInitialized = false;
      _isInitializing = false;
      _lastContext = null;
      debugPrint("WalletConnectService: Reset completed");
    } catch (e) {
      debugPrint("WalletConnectService: Error during reset: $e");
    }
  }
  
  WalletConnectService._internal();

  Future<void> initialize(BuildContext context) async {
    // 检查上下文是否相同，如果不同则强制重置
    if (_lastContext != null && _lastContext != context) {
      debugPrint("WalletConnectService: Context changed, forcing reset");
      _reset();
    }
    
    // 保存当前上下文
    _lastContext = context;
    
    if (isInitialized) {
      debugPrint("WalletConnectService: Already initialized, skipping.");
      return;
    }

    if (_isInitializing) {
      debugPrint("WalletConnectService: Initialization already in progress, skipping.");
      // 如果初始化正在进行，等待一段时间后返回
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    _isInitializing = true;
    
    try {
      debugPrint("WalletConnectService: Starting initialization...");
      
      // 确保项目ID是有效的
      const projectId = '07508ae6495c6f3d32155cb5d27048f8';
      debugPrint("WalletConnectService: Using project ID: $projectId");
      
      // 强制等待一小段时间，确保上一个实例完全清理
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 使用隔离的builder函数创建实例，减少冲突风险
      _appkitModal = await _buildAppKitModal(rootNavigatorKey.currentContext!, projectId);
      
      debugPrint("WalletConnectService: ReownAppKitModal instance created");
      
      // 延迟以确保上下文已准备好
      await Future.delayed(const Duration(seconds: 1));
      
      debugPrint("WalletConnectService: Initializing AppKitModal...");
      await _appkitModal!.init();
      debugPrint("WalletConnectService: AppKitModal initialized");
      
      // update wallet address in wallet provider
      debugPrint("WalletConnectService: Updating wallet address");
      try {
        updateWalletAddress(rootNavigatorKey.currentContext!);
        debugPrint("WalletConnectService: Wallet address updated successfully");
      } catch (e) {
        debugPrint("WalletConnectService: Error updating wallet address: $e");
        // 不要中断初始化流程，继续订阅事件
      }

      debugPrint("WalletConnectService: Subscribing to events");
      await subscribeToEvents(rootNavigatorKey.currentContext!);
      debugPrint("WalletConnectService: Events subscribed successfully");
      
      isInitialized = true;
      
      debugPrint("WalletConnectService: Initialization completed successfully");
       
    } catch (e) {
      debugPrint("WalletConnectService: Error initializing WalletConnectService: $e");
      _appkitModal = null;
      isInitialized = false;
      throw Exception("Failed to initialize wallet connect service: $e");
    } finally {
      _isInitializing = false;
    }
  }

  // 使用隔离的函数创建AppKitModal实例，避免冲突
  Future<ReownAppKitModal> _buildAppKitModal(BuildContext context, String projectId) async {
    try {
      return ReownAppKitModal(
        context: rootNavigatorKey.currentContext!,
        projectId: projectId,
        metadata: const PairingMetadata(
          name: 'University Blockchain Voting',
          description: 'App description',
          url: 'https://reown.com',
          icons: ['https://reown.com/logo.png'],
          redirect: Redirect(
            native: 'exampleapp://',
            universal: 'https://reown.com/exampleapp',
            linkMode: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint("WalletConnectService: Error creating ReownAppKitModal: $e");
      throw Exception("Failed to create ReownAppKitModal: $e");
    }
  }

  Future<ReownAppKitModal> getAppKitModalAsync(BuildContext context) async {
    if (!isInitialized || _appkitModal == null) {
      debugPrint("WalletConnectService: AppKitModal not initialized, initializing now...");
      await initialize(rootNavigatorKey.currentContext!);
    }
    
    if (_appkitModal == null) {
      throw Exception('Failed to initialize WalletConnectService');
    }
    
    return _appkitModal!;
  }

  ReownAppKitModal getAppKitModal(BuildContext context) {
    if (!isInitialized || _appkitModal == null) {
      debugPrint("WalletConnectService: AppKitModal not initialized, scheduling initialization");
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        initialize(rootNavigatorKey.currentContext!);
      });
      throw Exception('WalletConnectService not initialized. Please call initialize() first or use getAppKitModalAsync().');
    }
    return _appkitModal!;
  }

  Future<void> subscribeToEvents(BuildContext context) async {
    if (_appkitModal == null) {
      debugPrint("WalletConnectService: Cannot subscribe to events, AppKitModal is null");
      return;
    }
    
    debugPrint("WalletConnectService: Subscribing to events");
    
    _appkitModal!.onModalConnect.subscribe((ModalConnect? event) async {
      final userProvider = Provider.of<UserProvider>(rootNavigatorKey.currentContext!, listen: false);
      final user = userProvider.user;

      // userviewmodel got user, means user is logged in
      if (user != null) {
        // if user's wallet address is not the same as the event's address
        if (user.walletAddress == "" || user.walletAddress.isEmpty) {
          // update wallet address in provider and firestore
          print("WalletConnectService: User's wallet address is empty, updating wallet address");
          await userProvider.updateUser(userProvider.user!.copyWith(walletAddress: getWalletAddress(context)));
          updateWalletAddress(context);
          SnackbarUtil.showSnackBar(context, AppLocale.walletConnected.getString(context));
          return;
        } else if (user.walletAddress != "" && user.walletAddress.isNotEmpty && user.walletAddress != getWalletAddress(context)) {
          // prompt error and disconnect wallet
          print("WalletConnectService: User's wallet address is not the same as the event's address");
          handleDisconnect(context, false);
          SnackbarUtil.showSnackBar(context, "Wallet address is not the same as the event's address");
          return;
        } else {
          print("WalletConnectService: User's wallet address is the same as the event's address");
          updateWalletAddress(context);
          SnackbarUtil.showSnackBar(context, AppLocale.walletConnected.getString(context));
          return;
        }
      }
      print("WalletConnectService: User is not logged in, logging in with Metamask");
      updateWalletAddress(context);
      authService.loginWithMetamask(context);
    });

    _appkitModal!.onModalDisconnect.subscribe((ModalDisconnect? event) {
      if (_appkitModal!.isConnected) {
        handleDisconnect(context, true);
      }
    });

    _appkitModal!.onModalError.subscribe((ModalError? event) {
      if (event?.message.contains('expired') ?? false) {
        handleDisconnect(context, true);
      }
    });

    _appkitModal!.onModalNetworkChange.subscribe((ModalNetworkChange? event) {});
    _appkitModal!.onModalUpdate.subscribe((ModalConnect? event) {});
  }

  void unsubscribeFromEvents() {
    if (_appkitModal == null) return;
    
    _appkitModal!.onModalConnect.unsubscribe((ModalConnect? event) {});
    _appkitModal!.onModalDisconnect.unsubscribe((ModalDisconnect? event) {});
    _appkitModal!.onModalError.unsubscribe((ModalError? event) {});
    _appkitModal!.onModalNetworkChange.unsubscribe((ModalNetworkChange? event) {});
    _appkitModal!.onModalUpdate.unsubscribe((ModalConnect? event) {});
  }

  String checkChainIDsNullable(chainId) {
    if (chainId == null) {
      throw Exception("no available chainID");
    }
    return chainId;
  }

  Future<void> connectWalletWithAccount(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    if (userProvider.user?.walletAddress != null) {
      return;
    }

    userProvider.updateUser(userProvider.user!.copyWith(walletAddress: walletProvider.walletAddress));
  }

  Future<void> handleDisconnect(BuildContext context, [bool logout = true]) async {
    final walletProvider = Provider.of<WalletProvider>(rootNavigatorKey.currentContext!, listen: false);
    
    try {
      if ((_appkitModal?.isConnected ?? false)) {
        print("WalletConnectService: Disconnecting from wallet");
        unsubscribeFromEvents();
        await _appkitModal?.disconnect();
        walletProvider.removeAddress();
      }
      
      if (context.mounted && logout) {
        await authService.logout(context);
      }
    } catch (e) {
      debugPrint('Error during disconnect handling: $e');
    }
  }

  void updateWalletAddress(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    String address = getWalletAddress(context);
    debugPrint("Wallet address gained: $address");

    if (address.startsWith('0x') && address.length == 42) {
        walletProvider.updateAddress(address);
        debugPrint("WalletConnectService: Connected to wallet: $address");
    } else {
        debugPrint('Invalid wallet address: $address');
    }
  }

  String getWalletAddress(BuildContext context) {
    String chainId = _appkitModal!.selectedChain?.chainId ?? 'No Chain ID';
    final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
    final address = _appkitModal!.session?.getAddress(namespace) ?? 'No wallet address';
    return address;
  }
}
