import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/category.dart';
import '../../providers/expense_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  final ExpenseCategory? category;
  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  late final TextEditingController _nameController;
  late String _selectedIcon;
  late Color _selectedColor;

  bool get _isEditing => widget.category != null;

  static const List<Color> availableColors = [
    Colors.orange,
    Colors.blue,
    Colors.pink,
    Colors.red,
    Colors.purple,
    Colors.green,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.iconName ?? 'restaurant';
    _selectedColor = widget.category != null
        ? Color(widget.category!.colorValue)
        : Colors.orange;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppUtils.showSnackBar(context, 'Please enter a category name');
      return;
    }

    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    if (_isEditing) {
      final category = widget.category!;
      category.name = name;
      category.colorValue = _selectedColor.value;
      category.iconName = _selectedIcon;
      await provider.updateCategory(category);
      if (mounted) {
        AppUtils.showSnackBar(context, 'Category "$name" updated!');
        Navigator.pop(context);
      }
    } else {
      final category = ExpenseCategory(
        name: name,
        colorValue: _selectedColor.value,
        iconName: _selectedIcon,
      );
      await provider.addCategory(category);
      if (mounted) {
        AppUtils.showSnackBar(context, 'Category "$name" added!');
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bg : const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surface1 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _selectedColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _selectedColor, width: 2),
                    ),
                    child: Icon(
                      AppUtils.getIconData(_selectedIcon),
                      color: _selectedColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nameController.text.isEmpty
                        ? (_isEditing ? widget.category!.name : 'Category Name')
                        : _nameController.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextFormField(
              controller: _nameController,
              style: TextStyle(
                color: isDark ? AppTheme.textHigh : const Color(0xFF14141C),
                fontSize: 15,
              ),
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Groceries, Gym, Coffee',
                fillColor: isDark ? AppTheme.surface2 : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primary, width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // Color Picker
            const Text(
              'Choose Color',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: isDark ? Colors.white : Colors.black87,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Icon Picker
            const Text(
              'Choose Icon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: AppUtils.availableIcons.length,
              itemBuilder: (context, index) {
                final iconName = AppUtils.availableIcons[index];
                final isSelected = _selectedIcon == iconName;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconName),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withOpacity(0.2)
                          : (isDark ? AppTheme.surface2 : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? _selectedColor
                            : (isDark ? AppTheme.outline : const Color(0xFFE5E5F0)),
                        width: isSelected ? 2 : 0.5,
                      ),
                    ),
                    child: Icon(
                      AppUtils.getIconData(iconName),
                      color: isSelected ? _selectedColor : AppTheme.textMedium,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Primary Gradient Save Button
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _save,
                child: Text(
                  _isEditing ? 'UPDATE CATEGORY' : 'SAVE CATEGORY',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
