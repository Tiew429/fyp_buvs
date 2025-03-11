import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/services/auth_service.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'dart:async';

class WalletConnectService {
  ReownAppKitModal? _appkitModal;
  AuthService authService = AuthService();
  bool isInitialized = false;
  bool _isInitializing = false;

  final Completer<void> _initializationCompleter = Completer<void>();
  Future<void> get initializationComplete => _initializationCompleter.future;

  WalletConnectService._internal();
  static final WalletConnectService _instance = WalletConnectService._internal();
  factory WalletConnectService() => _instance;

  Future<void> initialize(BuildContext context) async {
    if (isInitialized) {
      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.complete();
      }
      return;
    }

    if (_isInitializing) {
      return await initializationComplete;
    }

    _isInitializing = true;
    try {
      debugPrint("WalletConnectService: Starting initialization...");
      
      _appkitModal = ReownAppKitModal(
        context: context,
        projectId: '07508ae6495c6f3d32155cb5d27048f8',
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
      
      await Future.delayed(const Duration(seconds: 1));
      
      await _appkitModal!.init();
      // update wallet address in wallet provider
      updateWalletAddress(context);

      await subscribeToEvents(context);
      isInitialized = true;
      
      debugPrint("WalletConnectService: Initialization completed successfully");
      
      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.complete();
      }
    } catch (e) {
      debugPrint("Error initializing WalletConnectService: $e");
      _appkitModal = null;
      isInitialized = false;
      
      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.completeError(e);
      }
      
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<ReownAppKitModal> getAppKitModalAsync(BuildContext context) async {
    if (!isInitialized || _appkitModal == null) {
      debugPrint("WalletConnectService: AppKitModal not initialized, initializing now...");
      await initialize(context);
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
        initialize(context);
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
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // userviewmodel got user, means user is logged in
      if (userProvider.user != null) {
        // if user's wallet address is not the same as the event's address
        if (userProvider.user!.walletAddress != getWalletAddress(context) && userProvider.user!.walletAddress.isNotEmpty) {
          // prompt error and disconnect wallet
          handleDisconnect(context, false);
        } else if (userProvider.user!.walletAddress.isEmpty) {
          // update wallet address in provider and firestore
          await userProvider.updateUser(userProvider.user!.copyWith(walletAddress: getWalletAddress(context)));
          updateWalletAddress(context);
          return;
        } else {
          updateWalletAddress(context);
          return;
        }
      }

      updateWalletAddress(context);
      authService.loginWithMetamask(context);
    });

    _appkitModal!.onModalDisconnect.subscribe((ModalDisconnect? event) {
      if (_appkitModal!.isConnected) {
        handleDisconnect(context);
      }
    });

    _appkitModal!.onModalError.subscribe((ModalError? event) {
      if (event?.message.contains('expired') ?? false) {
        handleDisconnect(context);
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
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    
    try {
      if (_appkitModal?.isConnected ?? false) {
        unsubscribeFromEvents();
        await _appkitModal?.disconnect();
        walletProvider.removeAddress();
      }
      
      if (context.mounted && logout) {
        authService.logout(context);
      }
    } catch (e) {
      debugPrint('Error during disconnect handling: $e');
    }
  }

  void updateWalletAddress(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    String address = getWalletAddress(context);

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
