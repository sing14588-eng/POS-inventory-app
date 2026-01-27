import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/models/product_model.dart';
import 'package:pos_app/utils/app_theme.dart';
import 'package:pos_app/screens/barcode_scanner_screen.dart';
import 'package:pos_app/utils/validators.dart';
import 'package:pos_app/services/sensory_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _fruitQtyController = TextEditingController(text: '0');
  final _stockController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _barcodeController = TextEditingController();

  // State
  String _category = 'Balloon';
  String _size = 'Small';
  String _unitType = 'PIECE';
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final product = Product(
      id: '',
      name: _nameController.text,
      category: _category,
      size: _size,
      fruitQuantity: int.tryParse(_fruitQtyController.text) ?? 0,
      unitType: _unitType,
      currentStock: int.parse(_stockController.text),
      shelfLocation: _locationController.text,
      price: int.parse(_priceController.text),
      barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
    );

    final success = await Provider.of<AppDataProvider>(context, listen: false)
        .createProduct(product);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        SensoryService.playSuccess();
        SensoryService.successVibration();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Product Added Successfully'),
              backgroundColor: Colors.green),
        );
      } else {
        SensoryService.playError();
        SensoryService.errorVibration();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to add product'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Product Name',
                icon: Icons.inventory_2_outlined,
                validator: (v) =>
                    Validators.required(v, error: 'Product name is required'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Price',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.positiveNumber(v, fieldName: 'Price'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _stockController,
                      label: 'Initial Stock',
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.number(v, fieldName: 'Stock'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Barcode (Optional)',
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.center_focus_weak),
                    onPressed: () async {
                      final code = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BarcodeScannerScreen(),
                        ),
                      );
                      if (code != null) {
                        setState(() => _barcodeController.text = code);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Category'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Balloon', 'Cushion'].map((cat) {
                  return ChoiceChip(
                    label: Text(cat),
                    selected: _category == cat,
                    onSelected: (selected) => setState(() => _category = cat),
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: _category == cat
                          ? AppTheme.primaryColor
                          : Colors.black87,
                      fontWeight: _category == cat
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Characteristics'),
              const SizedBox(height: 8),
              const Text('Size', style: TextStyle(color: Colors.grey)),
              DropdownButtonFormField<String>(
                initialValue: _size,
                decoration:
                    const InputDecoration(prefixIcon: Icon(Icons.straighten)),
                items: ['Small', 'Medium', 'Large']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _size = v!),
              ),
              const SizedBox(height: 16),
              const Text('Unit Type', style: TextStyle(color: Colors.grey)),
              Row(
                children: ['PIECE', 'WEIGHT'].map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: _unitType == type,
                      onSelected: (s) => setState(() => _unitType = type),
                    ),
                  );
                }).toList(),
              ),
              if (_category == 'Cushion') ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _fruitQtyController,
                  label: 'Fruit Quantity (Optional)',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v != null &&
                        v.isNotEmpty &&
                        double.tryParse(v) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              _buildSectionHeader('Location'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _locationController,
                label: 'Shelf Location',
                icon: Icons.location_on_outlined,
                validator: (v) =>
                    Validators.required(v, error: 'Location is required'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Save Product'),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
