import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../helpers/db/database_helper.dart';
import '../../helpers/db/dao/category_dao.dart';
import '../../helpers/db/models/insert_transaction_model.dart';
import '../../helpers/providers/transaction_provider.dart';

// Định nghĩa theme colors
class AppColors {
  static const primary = Color(0xFF00B2E7);
  static const secondary = Color(0xFFE064F7);
  static const tertiary = Color(0xFFFF8D6C);
  static final surface = Colors.grey.shade100;
  static const onSurface = Colors.black;
  static final outline = Colors.grey.shade400;
}

class AddExpense extends StatefulWidget {
  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _transactionType = "expense";
  int _categoryId = 0;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = await DatabaseHelper().database;
    final categoryDao = CategoryDao();
    final categoryData = await categoryDao.fetchCategories(db, _transactionType);

    setState(() {
      _categories = categoryData;
      if (_categories.isNotEmpty) {
        _categoryId = _categories[0]['id'];
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
              secondary: AppColors.secondary,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() async {
    if (_amountController.text.isEmpty || _categoryId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Vui lòng nhập đủ thông tin giao dịch"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final insertTransactionData = InsertTransactionModel(
      amount: int.parse(_amountController.text.replaceAll(',', '')),
      note: _noteController.text,
      categoryType: _transactionType,
      categoryId: _categoryId,
      date: _selectedDate,
    );

    await context.read<TransactionProvider>().addTransaction(insertTransactionData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Giao dịch đã được lưu thành công!"),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          "Thêm Giao Dịch",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.onSurface),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.outline.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTransactionTypeSegment(),
                  SizedBox(height: 20),
                  _buildAmountInput(),
                  SizedBox(height: 20),
                  _buildCategoryDropdown(),
                  SizedBox(height: 20),
                  _buildDatePicker(),
                  SizedBox(height: 20),
                  _buildNoteInput(),
                  SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSegment() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTransactionTypeButton(
              "Khoản Thu",
              "income",
              AppColors.primary,
            ),
          ),
          Expanded(
            child: _buildTransactionTypeButton(
              "Khoản Chi",
              "expense",
              AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeButton(String text, String type, Color activeColor) {
    final isSelected = _transactionType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _transactionType = type;
          _loadCategories();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Số Tiền",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            TextInputFormatter.withFunction((oldValue, newValue) {
              final text = newValue.text;
              return TextEditingValue(
                text: text.isNotEmpty
                    ? NumberFormat('#,###').format(int.parse(text.replaceAll(',', '')))
                    : '',
                selection: TextSelection.collapsed(offset: text.length),
              );
            }),
          ],
          decoration: InputDecoration(
            prefixText: "₫ ",
            prefixStyle: TextStyle(color: AppColors.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Danh Mục",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _categoryId,
          hint: Text("Chọn danh mục"),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (int? newValue) {
            setState(() {
              _categoryId = newValue!;
            });
          },
          items: _categories.map<DropdownMenuItem<int>>((category) {
            return DropdownMenuItem<int>(
              value: category['id'],
              child: Row(
                children: [
                  Icon(Icons.category, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text(
                    category['name'] ?? 'Không có tên',
                    style: TextStyle(color: AppColors.onSurface),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ngày Giao Dịch",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ghi Chú",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: "Ghi chú",
            prefixIcon: Icon(Icons.notes, color: AppColors.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),  // Adjust vertical padding here
          ),
          maxLines: 3,
          style: TextStyle(color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final primaryColor = Theme.of(context).colorScheme.primary;  // Lấy màu primary từ Theme
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;  // Lấy màu chữ trên primary từ Theme

    return ElevatedButton(
      onPressed: _saveTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,  // Dùng màu primary từ Theme
        foregroundColor: onPrimaryColor,  // Dùng màu chữ trên primary từ Theme
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save),
          SizedBox(width: 12),
          Text(
            "Lưu Giao Dịch",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}