import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/utils/app_theme.dart';

class BrandingWorkshopScreen extends StatefulWidget {
  const BrandingWorkshopScreen({super.key});

  @override
  State<BrandingWorkshopScreen> createState() => _BrandingWorkshopScreenState();
}

class _BrandingWorkshopScreenState extends State<BrandingWorkshopScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _logoController;
  late TextEditingController _currencyController;
  late String _selectedColor;
  bool _isSaving = false;

  final List<String> _colorPresets = [
    '#2563EB', // Blue
    '#DC2626', // Red
    '#059669', // Emerald
    '#D97706', // Amber
    '#7C3AED', // Violet
    '#000000', // Black
  ];

  @override
  void initState() {
    super.initState();
    final company =
        Provider.of<AuthProvider>(context, listen: false).currentCompany;
    _nameController = TextEditingController(text: company?.name ?? '');
    _logoController = TextEditingController(text: company?.logoUrl ?? '');
    _currencyController =
        TextEditingController(text: company?.currencySymbol ?? '\$');
    _selectedColor = company?.primaryColor ?? '#2563EB';
  }

  Future<void> _saveBranding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final success = await Provider.of<AppDataProvider>(context, listen: false)
        .updateOwnCompany({
      'name': _nameController.text,
      'logoUrl': _logoController.text,
      'primaryColor': _selectedColor,
      'currencySymbol': _currencyController.text,
    });

    if (success && mounted) {
      // Refresh user data to update the local company object
      await Provider.of<AuthProvider>(context, listen: false).refreshUserData();
      if (mounted) Navigator.pop(context);
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = AppTheme.hexToColor(_selectedColor);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branding Workshop'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Visual Identity',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1)),
              const Text('Customize how your shop appears to your team.',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),

              // Live Preview Card
              _buildPreviewCard(themeColor),

              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name',
                  prefixIcon: Icon(Icons.storefront_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _logoController,
                decoration: const InputDecoration(
                  labelText: 'Logo URL',
                  prefixIcon: Icon(Icons.link_rounded),
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/logo.png',
                ),
                onChanged: (v) => setState(() {}),
              ),
              const SizedBox(height: 16),

              const Text('Primary Brand Color',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: _colorPresets.map((hex) {
                  final color = AppTheme.hexToColor(hex);
                  final isSelected = _selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2)
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              TextFormField(
                controller: _currencyController,
                decoration: const InputDecoration(
                  labelText: 'Currency Symbol',
                  prefixIcon: Icon(Icons.payments_rounded),
                  border: OutlineInputBorder(),
                ),
                maxLength: 3,
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveBranding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Publish Brand Updates',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor, themeColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: _logoController.text.isNotEmpty
                ? Image.network(_logoController.text,
                    width: 50,
                    height: 50,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.storefront, color: themeColor, size: 40))
                : Icon(Icons.storefront, color: themeColor, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text.isEmpty
                ? 'Your Shop Name'
                : _nameController.text,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Live Dashboard Preview',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          )
        ],
      ),
    );
  }
}
