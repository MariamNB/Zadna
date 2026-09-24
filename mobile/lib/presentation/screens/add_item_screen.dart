import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../core/kitchen_theme.dart';
import '../../data/models/inventory_item.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategoryKey;
  String? _selectedUnitKey;
  String? _selectedStorageLocationId;
  String? _selectedStatus = 'stored';
  bool _isHomemade = false;
  DateTime? _preparedAt;
  DateTime? _frozenAt;
  DateTime? _openedAt;
  DateTime? _expiresAt;
  DateTime? _dateAdded;

  List<LocalizedLabel> _categories = [];
  List<LocalizedLabel> _units = [];
  List<StorageLocation> _storageLocations = [];
  bool _isLoadingRefData = true;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    setState(() => _isLoadingRefData = true);
    try {
      final n = ref.read(inventoryNotifierProvider.notifier);
      final results = await Future.wait([
        n.getCategories(),
        n.getUnits(),
        n.getStorageLocations(),
      ]);
      setState(() {
        _categories = results[0] as List<LocalizedLabel>;
        _units = results[1] as List<LocalizedLabel>;
        _storageLocations = results[2] as List<StorageLocation>;
        _isLoadingRefData = false;
      });
    } catch (_) {
      setState(() => _isLoadingRefData = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryKey == null) { _snack('Select a category'); return; }
    if (_selectedUnitKey == null)     { _snack('Select a unit'); return; }
    if (_selectedStorageLocationId == null) { _snack('Select a storage location'); return; }

    try {
      await ref.read(inventoryNotifierProvider.notifier).createItem(
        name: _nameController.text.trim(),
        categoryKey: _selectedCategoryKey!,
        quantity: _quantityController.text,
        unitKey: _selectedUnitKey!,
        storageLocationId: _selectedStorageLocationId!,
        preparedAt: _preparedAt?.toIso8601String().split('T').first,
        frozenAt: _frozenAt?.toIso8601String().split('T').first,
        openedAt: _openedAt?.toIso8601String().split('T').first,
        expiresAt: _expiresAt?.toIso8601String().split('T').first,
        isHomemade: _isHomemade,
        status: _selectedStatus ?? 'stored',
        dateAdded: _dateAdded?.toIso8601String().split('T').first,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      _snack('Item added!');
    } catch (e) {
      if (!mounted) return;
      _snack('Error: $e');
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, style: KT.poppins(color: Colors.white, weight: FontWeight.w500)),
      backgroundColor: KT.kDarkBlue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryNotifierProvider);
    final isLoading = inventoryState.isLoading;

    return Scaffold(
      backgroundColor: KT.kLightYellow,
      body: Column(
        children: [
          // Dark blue header
          Container(
            decoration: const BoxDecoration(
              color: KT.kDarkBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 8,
              right: 16,
              bottom: 20,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: KT.kLightYellow),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New Item', style: KT.poppins(size: 13, color: KT.kDarkYellow, weight: FontWeight.w500)),
                      Text('Add to board', style: KT.poppins(size: 18, weight: FontWeight.w700, color: KT.kLightYellow)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KT.kGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Save', style: KT.poppins(weight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: _isLoadingRefData
                ? Center(child: CircularProgressIndicator(color: KT.kGreen))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Basic Info card ──────────────────────────────
                          _Card(
                            color: KT.kLightYellow2,
                            accent: KT.kDarkYellow,
                            title: 'Item Info',
                            child: Column(children: [
                              _Field(
                                controller: _nameController,
                                label: 'Item Name',
                                hint: 'e.g. Chicken Breast, Milk...',
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter item name' : null,
                              ),
                              const SizedBox(height: 14),
                              _Drop<String>(
                                value: _selectedCategoryKey,
                                label: 'Category',
                                items: _categories.map((c) => DropdownMenuItem(
                                  value: c.key,
                                  child: Text(c.labels['en'] ?? c.key, style: KT.poppins()),
                                )).toList(),
                                onChanged: (v) => setState(() => _selectedCategoryKey = v),
                                validator: (v) => v == null ? 'Select a category' : null,
                              ),
                              const SizedBox(height: 14),
                              // Amount row: quantity + unit side by side
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _Field(
                                      controller: _quantityController,
                                      label: 'Quantity',
                                      hint: '1.5',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'Required';
                                        if ((double.tryParse(v) ?? 0) <= 0) return 'Invalid';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: _Drop<String>(
                                      value: _selectedUnitKey,
                                      label: 'Unit',
                                      items: _units.map((u) => DropdownMenuItem(
                                        value: u.key,
                                        child: Text(u.labels['en'] ?? u.key, style: KT.poppins()),
                                      )).toList(),
                                      onChanged: (v) => setState(() => _selectedUnitKey = v),
                                      validator: (v) => v == null ? 'Select unit' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _Drop<String>(
                                value: _selectedStorageLocationId,
                                label: 'Storage Location',
                                items: _storageLocations.map((loc) => DropdownMenuItem(
                                  value: loc.id,
                                  child: Text(loc.name, style: KT.poppins()),
                                )).toList(),
                                onChanged: (v) => setState(() => _selectedStorageLocationId = v),
                                validator: (v) => v == null ? 'Select a location' : null,
                              ),
                              const SizedBox(height: 14),
                              _Drop<String>(
                                value: _selectedStatus,
                                label: 'Status',
                                items: const [
                                  DropdownMenuItem(value: 'stored',    child: Text('✓ Stored')),
                                  DropdownMenuItem(value: 'thawing',   child: Text('🧊 Thawing')),
                                  DropdownMenuItem(value: 'consumed',  child: Text('✓ Consumed')),
                                  DropdownMenuItem(value: 'discarded', child: Text('✗ Discarded')),
                                ],
                                onChanged: (v) => setState(() => _selectedStatus = v),
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                title: Text('Homemade 🏠', style: KT.poppins(weight: FontWeight.w600)),
                                value: _isHomemade,
                                onChanged: (v) => setState(() => _isHomemade = v),
                                activeColor: KT.kGreen,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ]),
                          ),

                          const SizedBox(height: 16),

                          // ── Dates card ───────────────────────────────────
                          _Card(
                            color: KT.kLightGreen,
                            accent: KT.kGreen,
                            title: 'Dates',
                            child: Column(children: [
                              _DateRow('Prepared', '👨‍🍳', _preparedAt, (d) => setState(() => _preparedAt = d)),
                              _DateRow('Frozen',   '❄️',  _frozenAt,   (d) => setState(() => _frozenAt = d)),
                              _DateRow('Opened',   '📂',  _openedAt,   (d) => setState(() => _openedAt = d)),
                              _DateRow('Expires',  '⏰',  _expiresAt,  (d) => setState(() => _expiresAt = d)),
                              _DateRow('Date Added','📌', _dateAdded,  (d) => setState(() => _dateAdded = d), initialDate: DateTime.now()),
                            ]),
                          ),

                          const SizedBox(height: 16),

                          // ── Notes card ───────────────────────────────────
                          _Card(
                            color: KT.kLavender,
                            accent: KT.kBlue,
                            title: 'Notes',
                            child: TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              maxLength: 500,
                              style: KT.poppins(style: FontStyle.italic),
                              decoration: InputDecoration(
                                hintText: 'Any notes about this item...',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: KT.kBlue.withOpacity(0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: KT.kBlue.withOpacity(0.3)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _DateRow(String label, String emoji, DateTime? value, ValueChanged<DateTime> onChanged, {DateTime? initialDate}) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? initialDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) onChanged(date);
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text(label, style: KT.poppins(size: 13, weight: FontWeight.w600)),
            const Spacer(),
            Text(
              value != null ? '${value.day}/${value.month}/${value.year}' : 'Tap to set',
              style: KT.poppins(
                size: 12,
                color: value != null ? KT.kGreen : Colors.black38,
                weight: value != null ? FontWeight.w600 : FontWeight.w400,
                style: value != null ? FontStyle.normal : FontStyle.italic,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.calendar_today_outlined, size: 14,
                color: value != null ? KT.kGreen : Colors.black26),
          ],
        ),
      ),
    );
  }
}

// ── Shared form widgets ───────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Color color;
  final Color accent;
  final String title;
  final Widget child;
  const _Card({required this.color, required this.accent, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: accent.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(title, style: KT.poppins(size: 13, weight: FontWeight.w700, color: accent)),
            ]),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _Field({required this.controller, required this.label, required this.hint, this.keyboardType, this.validator});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: KT.poppins(weight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: KT.kGreen, width: 2)),
        ),
      );
}

class _Drop<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  const _Drop({required this.value, required this.label, required this.items, required this.onChanged, this.validator});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        style: KT.poppins(weight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: KT.kGreen, width: 2)),
        ),
      );
}
