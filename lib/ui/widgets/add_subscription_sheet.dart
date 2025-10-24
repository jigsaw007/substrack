import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/subscription.dart';
import '../../state/providers.dart';
import 'dart:ui'; // For blur effect

class AddSubscriptionSheet extends ConsumerStatefulWidget {
  const AddSubscriptionSheet({super.key});

  @override
  ConsumerState<AddSubscriptionSheet> createState() =>
      _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends ConsumerState<AddSubscriptionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _categoryController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCycle = 'Monthly';
  bool _isSaving = false;
  List<String> _categoryOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await client
          .from('subscriptions')
          .select('category')
          .eq('user_id', user.id)
          .not('category', 'is', null);

      final categories = (response as List)
          .map((e) => e['category']?.toString().trim())
          .where((c) => c != null && c!.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      setState(() => _categoryOptions = categories);
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in first.')),
        );
        return;
      }

      final newSub = Subscription(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        cycle: _selectedCycle.toLowerCase(),
        renewalDate: _selectedDate,
        userId: user.id,
        category: _categoryController.text.trim().isEmpty
            ? 'Other'
            : _categoryController.text.trim(),
        notes: _notesController.text.trim(),
      );

      await ref.read(subscriptionsProvider.notifier).add(newSub);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription added successfully!')),
      );
    } catch (e) {
      debugPrint('Error adding subscription: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 28,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 5,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Add Subscription',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Service Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Service Name',
                        prefixIcon: const Icon(Icons.subscriptions_outlined),
                        border: inputBorder,
                        enabledBorder: inputBorder,
                        focusedBorder: inputBorder.copyWith(
                          borderSide: const BorderSide(color: Colors.teal),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter service name' : null,
                    ),
                    const SizedBox(height: 16),

                    // --- Price
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price (¥)',
                        prefixIcon: const Icon(Icons.payments_outlined),
                        border: inputBorder,
                        enabledBorder: inputBorder,
                        focusedBorder: inputBorder.copyWith(
                          borderSide: const BorderSide(color: Colors.teal),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter price' : null,
                    ),
                    const SizedBox(height: 16),

                    // --- Cycle Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCycle,
                      items: const [
                        DropdownMenuItem(
                            value: 'Monthly', child: Text('Monthly')),
                        DropdownMenuItem(
                            value: 'Yearly', child: Text('Yearly')),
                        DropdownMenuItem(
                            value: 'Weekly', child: Text('Weekly')),
                      ],
                      onChanged: (v) => setState(() => _selectedCycle = v!),
                      decoration: InputDecoration(
                        labelText: 'Billing Cycle',
                        prefixIcon: const Icon(Icons.repeat_outlined),
                        border: inputBorder,
                        enabledBorder: inputBorder,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Category (Autocomplete)
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _categoryOptions;
                        }
                        return _categoryOptions.where((option) => option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      fieldViewBuilder:
                          (context, textEditingController, focusNode, _) {
                        textEditingController.addListener(() {
                          _categoryController.text = textEditingController.text;
                        });
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: const Icon(Icons.category_outlined),
                            border: inputBorder,
                            enabledBorder: inputBorder,
                            focusedBorder: inputBorder.copyWith(
                              borderSide: const BorderSide(color: Colors.teal),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                          ),
                        );
                      },
                      onSelected: (String selection) {
                        _categoryController.text = selection;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Renewal Date
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Renewal Date',
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          border: inputBorder,
                          enabledBorder: inputBorder,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.teal),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Notes
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes (optional)',
                        prefixIcon: const Icon(Icons.note_alt_outlined),
                        border: inputBorder,
                        enabledBorder: inputBorder,
                        focusedBorder: inputBorder.copyWith(
                          borderSide: const BorderSide(color: Colors.teal),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- Save Button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: _isSaving
                              ? [Colors.teal.shade300, Colors.teal.shade400]
                              : [Colors.teal.shade400, Colors.teal.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        icon: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded,
                                color: Colors.white),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save Subscription',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isSaving ? null : _save,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
