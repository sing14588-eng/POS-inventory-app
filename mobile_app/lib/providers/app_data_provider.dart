import 'package:flutter/material.dart';
import 'package:pos_app/models/product_model.dart';
import 'package:pos_app/models/sale_model.dart';
import 'package:pos_app/models/company_model.dart';
import 'package:pos_app/services/api_service.dart';
import 'package:pos_app/services/offline_service.dart';
import 'package:pos_app/services/error_service.dart';
import 'package:pos_app/models/branch_model.dart';
import 'package:pos_app/models/notification_model.dart';
import 'package:pos_app/models/audit_log_model.dart';
import 'package:pos_app/models/supplier_model.dart';
import 'package:pos_app/models/purchase_order_model.dart';

class AppDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  List<Product> _filteredProducts = []; // For search
  List<Product> get products => _filteredProducts.isNotEmpty
      ? _filteredProducts
      : _products; // Return filtered if active

  List<Sale> _pickerOrders = [];
  List<Sale> get pickerOrders => _pickerOrders;

  List<Sale> _mySales = [];
  List<Sale> get mySales => _mySales;

  Map<String, dynamic>? _dailyReport;
  Map<String, dynamic>? get dailyReport => _dailyReport;

  List<Company> _companies = [];
  List<Company> get companies => _companies;

  Map<String, dynamic>? _globalStats;
  Map<String, dynamic>? get globalStats => _globalStats;

  bool _isLoadingCompanies = false;
  bool get isLoadingCompanies => _isLoadingCompanies;

  List<Branch> _branches = [];
  List<Branch> get branches => _branches;

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  List<AuditLog> _auditLogs = [];
  List<AuditLog> get auditLogs => _auditLogs;

  List<Supplier> _suppliers = [];
  List<Supplier> get suppliers => _suppliers;

  List<PurchaseOrder> _purchaseOrders = [];
  List<PurchaseOrder> get purchaseOrders => _purchaseOrders;

  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? get analytics => _analytics;

  int _unreadNotifications = 0;
  int get unreadNotifications => _unreadNotifications;

  // Pagination state
  int _productPage = 1;
  bool _hasMoreProducts = true;
  int _salesPage = 1;
  bool _hasMoreSales = true;

  bool get hasMoreProducts => _hasMoreProducts;
  bool get hasMoreSales => _hasMoreSales;

  Future<void> fetchProducts({bool refresh = true}) async {
    if (refresh) {
      _productPage = 1;
      _hasMoreProducts = true;
      _products = [];
    }
    if (!_hasMoreProducts) return;

    try {
      final data =
          await _apiService.get('/products?page=$_productPage&limit=50');

      List<Product> fetchedProducts = [];
      if (data is Map && data.containsKey('products')) {
        fetchedProducts =
            (data['products'] as List).map((i) => Product.fromJson(i)).toList();
        _hasMoreProducts = _productPage < (data['pages'] ?? 1);
        _productPage++;
      } else if (data is List) {
        fetchedProducts = data.map((i) => Product.fromJson(i)).toList();
        _hasMoreProducts = false; // Legacy fallback
      }

      _products =
          refresh ? fetchedProducts : [..._products, ...fetchedProducts];
      _filteredProducts = []; // Reset filter

      // Cache for offline use
      OfflineService().cacheProducts(_products);

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching products: $e");
      // Fallback to cache
      final cached = OfflineService().getCachedProducts();
      if (cached.isNotEmpty) {
        _products = cached;
        _filteredProducts = [];
        notifyListeners();
        debugPrint("Loaded ${cached.length} products from cache");
        ErrorService.showError("Offline Mode: Showing cached products");
      } else {
        ErrorService.showError("Failed to load products: Offline & No Cache");
      }
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = [];
    } else {
      _filteredProducts = _products
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
    notifyListeners();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      // First check local list
      final localMatch = _products.firstWhere((p) => p.barcode == barcode,
          orElse: () => Product(
              id: '',
              name: '',
              category: '',
              size: '',
              fruitQuantity: 0,
              unitType: '',
              currentStock: 0,
              shelfLocation: '',
              price: 0));

      if (localMatch.id.isNotEmpty) return localMatch;

      // If not found locally, check backend (maybe it wasn't fetched yet?)
      final data = await _apiService.get('/products?barcode=$barcode');
      final results = (data as List).map((i) => Product.fromJson(i)).toList();
      if (results.isNotEmpty) return results.first;

      return null;
    } catch (e) {
      debugPrint("Error fetching product by barcode: $e");
      return null;
    }
  }

  Future<void> fetchMySales({bool refresh = true}) async {
    if (refresh) {
      _salesPage = 1;
      _hasMoreSales = true;
      _mySales = [];
    }
    if (!_hasMoreSales) return;

    try {
      final data =
          await _apiService.get('/sales/my-sales?page=$_salesPage&limit=20');

      List<Sale> fetchedSales = [];
      if (data is Map && data.containsKey('sales')) {
        fetchedSales =
            (data['sales'] as List).map((i) => Sale.fromJson(i)).toList();
        _hasMoreSales = _salesPage < (data['pages'] ?? 1);
        _salesPage++;
      } else if (data is List) {
        fetchedSales = data.map((i) => Sale.fromJson(i)).toList();
        _hasMoreSales = false;
      }

      _mySales = refresh ? fetchedSales : [..._mySales, ...fetchedSales];
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching my sales: $e");
    }
  }

  Future<bool> createProduct(Product product) async {
    try {
      await _apiService.postAuth('/products', {
        'name': product.name,
        'category': product.category,
        'size': product.size,
        'fruitQuantity': product.fruitQuantity,
        'unitType': product.unitType,
        'currentStock': product.currentStock,
        'shelfLocation': product.shelfLocation,
        'price': product.price,
        'barcode': product.barcode,
      });
      await fetchProducts();
      ErrorService.showSuccess("Product created successfully");
      return true;
    } catch (e) {
      debugPrint(e.toString());
      ErrorService.showError("Failed to create product: $e");
      return false;
    }
  }

  Future<bool> updateProductStock(String productId, int newStock) async {
    try {
      await _apiService.put('/products/$productId', {
        'currentStock': newStock,
      });
      await fetchProducts();
      ErrorService.showSuccess("Stock updated successfully");
      return true;
    } catch (e) {
      debugPrint("Update stock error: $e");
      ErrorService.showError("Failed to update stock: $e");
      return false;
    }
  }

  Future<Sale?> createSale(List<SaleItem> items, bool isCredit) async {
    try {
      final data = await _apiService.postAuth('/sales', {
        'items': items.map((e) => e.toJson()).toList(),
        'isCredit': isCredit,
      });
      // Refresh products to show updated stock
      await fetchProducts();
      return Sale.fromJson(data);
    } catch (e) {
      debugPrint("Sales creation error: $e");
      // If offline, queue it
      if (!await OfflineService().isOnline) {
        final mockSale = {
          'items': items.map((e) => e.toJson()).toList(),
          'isCredit': isCredit,
          'totalAmount': items.fold(0.0, (sum, i) => sum + i.total),
          'vatAmount': items.fold(0.0, (sum, i) => sum + i.total) * 0.15,
          'createdAt': DateTime.now().toIso8601String(),
          '_id': 'OFFLINE_${DateTime.now().millisecondsSinceEpoch}',
        };
        await OfflineService().queueSale(mockSale);
        ErrorService.showError("Offline: Sale saved to queue");
        return Sale.fromJson(mockSale);
      }
      ErrorService.showError("Failed to process sale: $e");
      return null;
    }
  }

  Future<void> fetchPickerOrders() async {
    try {
      final data = await _apiService.get('/picker/orders');
      _pickerOrders = (data as List).map((i) => Sale.fromJson(i)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> markOrderPrepared(String saleId) async {
    try {
      await _apiService.put('/picker/orders/$saleId/prepare', {});
      await fetchPickerOrders();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> createRestockRequest(String productId) async {
    try {
      await _apiService.postAuth('/restock', {'productId': productId});
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Warehouse side
  List<dynamic> _restockRequests = [];
  List<dynamic> get restockRequests => _restockRequests;

  Future<void> fetchRestockRequests() async {
    try {
      final data = await _apiService.get('/restock');
      _restockRequests = data;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Credit Management logic
  List<Sale> _pendingCreditSales = [];
  List<Sale> get pendingCreditSales => _pendingCreditSales;

  Future<void> fetchPendingCreditSales() async {
    try {
      final data = await _apiService.get('/sales/credit/pending');
      _pendingCreditSales =
          (data as List).map((i) => Sale.fromJson(i)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch credit error: $e");
    }
  }

  Future<void> settleCreditSale(String saleId) async {
    try {
      await _apiService.put('/sales/$saleId/settle', {});
      await fetchPendingCreditSales();
      await fetchDailyReport(); // Refresh report too
    } catch (e) {
      debugPrint("Settle credit error: $e");
    }
  }

  Future<void> fetchDailyReport() async {
    try {
      final data = await _apiService.get('/reports/daily');
      _dailyReport = data;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fulfillRestockRequest(String requestId) async {
    try {
      await _apiService.put('/restock/$requestId/fulfill', {});
      await fetchRestockRequests();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> approveRefund(String saleId) async {
    try {
      await _apiService.put('/sales/$saleId/refund/approve', {});
      await fetchRefundRequests();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Refunds
  Future<bool> requestRefund(String saleId, String reason) async {
    try {
      await _apiService.postAuth('/sales/$saleId/refund', {'reason': reason});
      await fetchMySales(); // Refresh history
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Accountant side
  List<Sale> _refundRequests = [];
  List<Sale> get refundRequests => _refundRequests;

  Future<void> fetchRefundRequests() async {
    try {
      final data = await _apiService.get('/sales/refunds/pending');
      _refundRequests = (data as List).map((i) => Sale.fromJson(i)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch refunds error: $e");
    }
  }

  // Super Admin Methods
  Future<void> fetchCompanies() async {
    _isLoadingCompanies = true;
    notifyListeners();
    try {
      final data = await _apiService.get('/companies');
      _companies = (data as List).map((i) => Company.fromJson(i)).toList();
    } catch (e) {
      debugPrint("Fetch companies error: $e");
    } finally {
      _isLoadingCompanies = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createCompany(
      Map<String, dynamic> companyData) async {
    try {
      final response = await _apiService.postAuth('/companies', companyData);
      await fetchCompanies();
      return response;
    } catch (e) {
      debugPrint("Create company error: $e");
      return null;
    }
  }

  Future<bool> updateCompany(String id, Map<String, dynamic> body) async {
    try {
      await _apiService.put('/companies/$id', body);
      await fetchCompanies();
      return true;
    } catch (e) {
      debugPrint("Update company error: $e");
      return false;
    }
  }

  Future<bool> updateOwnCompany(Map<String, dynamic> body) async {
    try {
      await _apiService.put('/companies/me', body);
      // Success will return the updated company object
      ErrorService.showSuccess("Shop identity updated successfully");
      return true;
    } catch (e) {
      debugPrint("Update own company error: $e");
      ErrorService.showError("Failed to update branding: $e");
      return false;
    }
  }

  Future<bool> updateCompanyStatus(String id, bool isActive) async {
    try {
      await _apiService.put('/companies/$id/status', {'isActive': isActive});
      await fetchCompanies();
      await fetchGlobalStats();
      return true;
    } catch (e) {
      debugPrint("Update status error: $e");
      return false;
    }
  }

  Future<bool> resetAdminPassword(String id) async {
    try {
      await _apiService.put('/companies/$id/reset-password', {});
      return true;
    } catch (e) {
      debugPrint("Reset password error: $e");
      return false;
    }
  }

  Future<void> fetchGlobalStats() async {
    try {
      final data = await _apiService.get('/reports/global');
      _globalStats = data;
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch global stats error: $e");
    }
  }

  // Visual Analytics
  Future<void> fetchAnalytics() async {
    try {
      final data = await _apiService.get('/reports/analytics');
      _analytics = data;
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch analytics error: $e");
    }
  }

  Future<Map<String, dynamic>?> resetUserPassword(String userId) async {
    try {
      final data = await _apiService.put('/users/$userId/reset-password', {});
      ErrorService.showSuccess(
          "Password reset successfully. Please share the credentials.");
      return data;
    } catch (e) {
      debugPrint("Reset password error: $e");
      ErrorService.showError("Failed to reset password: $e");
      return null;
    }
  }

  // Branch Management
  Future<void> fetchBranches() async {
    try {
      final data = await _apiService.get('/branches');
      _branches = (data as List).map((i) => Branch.fromJson(i)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch branches error: $e");
    }
  }

  Future<bool> createBranch(Map<String, dynamic> body) async {
    try {
      await _apiService.postAuth('/branches', body);
      await fetchBranches();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBranchStatus(String id, bool isActive) async {
    try {
      await _apiService.put('/branches/$id', {'isActive': isActive});
      await fetchBranches();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Notifications
  Future<void> fetchNotifications() async {
    try {
      final data = await _apiService.get('/notifications');
      _notifications =
          (data as List).map((i) => AppNotification.fromJson(i)).toList();
      _unreadNotifications = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch notifications error: $e");
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await _apiService.put('/notifications/$id/read', {});
      await fetchNotifications();
    } catch (e) {
      debugPrint("Mark read error: $e");
    }
  }

  // Audit Logs
  Future<void> fetchAuditLogs() async {
    try {
      final data = await _apiService.get('/audit');
      _auditLogs =
          (data['logs'] as List).map((i) => AuditLog.fromJson(i)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch audit logs error: $e");
    }
  }

  // Inventory (Suppliers & POs)
  Future<void> fetchSuppliers() async {
    try {
      final data = await _apiService.get('/inventory/suppliers');
      _suppliers = (data as List).map((i) => Supplier.fromJson(i)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch suppliers error: $e");
    }
  }

  Future<bool> createSupplier(Map<String, dynamic> body) async {
    try {
      await _apiService.postAuth('/inventory/suppliers', body);
      await fetchSuppliers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchPurchaseOrders() async {
    try {
      final data = await _apiService.get('/inventory');
      _purchaseOrders =
          (data as List).map((i) => PurchaseOrder.fromJson(i)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch POs error: $e");
    }
  }

  Future<bool> createPO(Map<String, dynamic> body) async {
    try {
      await _apiService.postAuth('/inventory', body);
      await fetchPurchaseOrders();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePOStatus(String id, String status) async {
    try {
      await _apiService.put('/inventory/$id', {'status': status});
      await fetchPurchaseOrders();
      await fetchProducts(); // Stock might have updated
      return true;
    } catch (e) {
      return false;
    }
  }
}
