import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pos_app/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:pos_app/utils/constants.dart';
import 'package:pos_app/services/storage_service.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  static const String _productsBoxName = 'products';
  static const String _salesQueueBoxName = 'sales_queue';

  late Box? _productsBox;
  late Box? _salesQueueBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _productsBox = await Hive.openBox(_productsBoxName);
    _salesQueueBox = await Hive.openBox(_salesQueueBoxName);

    // Auto-sync on reconnect
    Connectivity().onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        debugPrint('OfflineService: Connection restored. Syncing...');
        syncPendingSales();
      }
    });
  }

  // --- Connectivity ---
  Future<bool> get isOnline async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    // Optional: Double check with an actual ping if needed, but for now connectivity check is enough
    return true;
  }

  // --- Products Caching ---
  Future<void> cacheProducts(List<Product> products) async {
    final List<Map<String, dynamic>> jsonList = products
        .map((p) => {
              '_id': p.id,
              'name': p.name,
              'category': p.category,
              'size': p.size,
              'fruitQuantity': p.fruitQuantity,
              'unitType': p.unitType,
              'currentStock': p.currentStock,
              'shelfLocation': p.shelfLocation,
              'price': p.price,
              'barcode': p.barcode,
            })
        .toList();

    await _productsBox!.put('all_products', jsonEncode(jsonList));
    debugPrint('OfflineService: Cached ${products.length} products');
  }

  List<Product> getCachedProducts() {
    if (_productsBox == null) return [];
    final String? jsonString = _productsBox!.get('all_products');
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint('OfflineService: Error decoding cached products: $e');
      return [];
    }
  }

  // --- Sales Queue ---
  Future<void> queueSale(Map<String, dynamic> saleData) async {
    if (_salesQueueBox == null) return;
    // Add timestamp to ensure unique keys or just use auto-increment
    await _salesQueueBox!.add(jsonEncode(saleData));
    debugPrint(
        'OfflineService: Queued sale. Queue size: ${_salesQueueBox!.length}');
  }

  Future<int> syncPendingSales() async {
    if (!await isOnline) return 0;
    if (_salesQueueBox == null || _salesQueueBox!.isEmpty) return 0;

    int syncedCount = 0;
    final Map<dynamic, dynamic> queueMap = _salesQueueBox!.toMap();
    final token = await StorageService().getToken();

    for (var key in queueMap.keys) {
      try {
        final String jsonString = queueMap[key];
        final Map<String, dynamic> saleData = jsonDecode(jsonString);

        // Attempt POST
        final response = await http.post(
          Uri.parse('${Constants.baseUrl}/sales'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(saleData), // already encoded? no, saleData is map
        );

        if (response.statusCode == 201) {
          await _salesQueueBox?.delete(key);
          syncedCount++;
        } else {
          debugPrint('OfflineService: Sync failed for $key: ${response.body}');
          // Keep in queue to retry later
        }
      } catch (e) {
        debugPrint('OfflineService: Sync error for $key: $e');
      }
    }
    return syncedCount;
  }
}
