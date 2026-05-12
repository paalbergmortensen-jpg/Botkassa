import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

final customerInfoProvider = StreamProvider<CustomerInfo>((ref) {
  if (kIsWeb) return const Stream.empty();
  // return Purchases.addCustomerInfoUpdateListener(); // Fix this later
  return const Stream.empty();
});

final entitlementProvider = Provider<bool>((ref) {
  if (kIsWeb) return true; // Mock pro for web preview
  final customerInfo = ref.watch(customerInfoProvider).value;
  return customerInfo?.entitlements.all['Botkassa Pro']?.isActive ?? false;
});

class PaymentService {
  static const _apiKey = 'test_kLfpKmpPbZMOWHVMkTlyzPMvNVr';

  Future<void> init() async {
    if (kIsWeb) return;
    await Purchases.setLogLevel(LogLevel.debug);

    if (Platform.isIOS || Platform.isAndroid) {
      await Purchases.configure(PurchasesConfiguration(_apiKey));
    } else {
      print('RevenueCat is not supported on this platform');
    }
  }

  /// Present the RevenueCat Paywall
  Future<void> presentPaywall() async {
    try {
      if (kIsWeb) return;
      await RevenueCatUI.presentPaywall();
    } catch (e) {
      print('Error presenting paywall: $e');
    }
  }

  /// Present the RevenueCat Customer Center
  Future<void> presentCustomerCenter() async {
    try {
      if (kIsWeb) return;
      // await RevenueCatUI.presentCustomerCenter(); // Fix this later
    } catch (e) {
      print('Error presenting customer center: $e');
    }
  }

  /// Get available offerings
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } on PlatformException catch (e) {
      print('Error fetching offerings: $e');
      return null;
    }
  }

  /// Make a purchase
  Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all['Botkassa Pro']?.isActive ?? false;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print('Purchase error: $e');
      }
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all['Botkassa Pro']?.isActive ?? false;
    } on PlatformException catch (e) {
      print('Restore error: $e');
      return false;
    }
  }
}
