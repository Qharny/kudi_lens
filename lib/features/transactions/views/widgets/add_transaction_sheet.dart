import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/account.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../accounts/data/account_provider.dart';
import '../../data/transaction_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final TransactionItem? initialTransaction;

  const AddTransactionSheet({
    super.key,
    this.initialTransaction,
  });

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  late TransactionType _selectedType;
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  String? _selectedCategory;
  String? _selectedAccountId;
  bool _createRule = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initialTransaction;
    _selectedType = init?.type ?? TransactionType.expense;
    _amountController = TextEditingController(
      text: init != null && init.amount > 0 ? init.amount.toStringAsFixed(2) : '',
    );
    _merchantController = TextEditingController(text: init?.merchant ?? '');
    _noteController = TextEditingController(text: init?.note ?? '');
    _selectedDate = init?.date ?? DateTime.now();
    _selectedCategory = init?.category ?? 'Food & Dining';
    _selectedAccountId = init?.accountId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onSave() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (widget.initialTransaction != null) {
      final updated = widget.initialTransaction!.copyWith(
        amount: amount,
        type: _selectedType,
        category: _selectedCategory,
        merchant: _merchantController.text.trim().isEmpty
            ? null
            : _merchantController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        date: _selectedDate,
        accountId: _selectedAccountId,
        status: TransactionStatus.confirmed,
        isIncome: _selectedType == TransactionType.income,
      );
      ref.read(transactionProvider.notifier).updateTransaction(updated);
    } else {
      ref.read(transactionProvider.notifier).quickAdd(
            amount: amount,
            type: _selectedType,
            category: _selectedCategory ?? 'Other',
            accountId: _selectedAccountId,
            merchant: _merchantController.text.trim().isEmpty
                ? null
                : _merchantController.text.trim(),
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountProvider);
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    final palette = context.palette;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 16,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Title
            Text(
              widget.initialTransaction != null
                  ? (widget.initialTransaction!.status.isPending
                      ? 'Categorize Bank Alert'
                      : 'Edit Transaction')
                  : 'Add Transaction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Segmented Transaction Type Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTypeTab(TransactionType.expense, 'Expense', AppColors.expense),
                  _buildTypeTab(TransactionType.income, 'Income', AppColors.income),
                  _buildTypeTab(TransactionType.transfer, 'Transfer', AppColors.transfer),
                  _buildTypeTab(TransactionType.fee, 'Fee', AppColors.fee),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Hero Amount Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: palette.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  const Text(
                    'GHS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      autofocus: widget.initialTransaction == null,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: palette.textMuted,
                          fontSize: 28,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Picker
            Text(
              'Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: palette.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: CategoryItem.defaultCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = CategoryItem.defaultCategories[index];
                  final isSelected = _selectedCategory == cat.name;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat.name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color.withOpacity(0.18)
                            : palette.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? cat.color : palette.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cat.icon,
                            size: 16,
                            color: isSelected ? cat.color : palette.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? palette.textPrimary
                                  : palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Account & Date Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account / Wallet',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: palette.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: palette.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedAccountId,
                            isExpanded: true,
                            dropdownColor: palette.surface,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 14,
                            ),
                            items: accounts.map((acc) {
                              return DropdownMenuItem<String>(
                                value: acc.id,
                                child: Text(acc.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedAccountId = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: palette.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: palette.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: palette.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormatter.formatShortDate(_selectedDate),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: palette.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Merchant / Recipient input
            TextField(
              controller: _merchantController,
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                labelText: 'Merchant / Recipient (Optional)',
                labelStyle: TextStyle(color: palette.textSecondary),
                filled: true,
                fillColor: palette.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: palette.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: palette.border),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Note input
            TextField(
              controller: _noteController,
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                labelStyle: TextStyle(color: palette.textSecondary),
                filled: true,
                fillColor: palette.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: palette.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: palette.border),
                ),
              ),
            ),

            // Raw Alert reference box if pre-filled
            if (widget.initialTransaction?.rawMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.mark_email_read_rounded,
                            size: 14, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Original Alert Message',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.initialTransaction!.rawMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Create learned rule toggle
            if (widget.initialTransaction?.narration != null) ...[
              const SizedBox(height: 10),
              CheckboxListTile(
                value: _createRule,
                onChanged: (val) => setState(() => _createRule = val ?? false),
                title: Text(
                  'Auto-categorize future alerts with "${widget.initialTransaction!.narration}"',
                  style: TextStyle(
                    fontSize: 12,
                    color: palette.textSecondary,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ],

            const SizedBox(height: 20),

            // Save Action Button
            ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.initialTransaction != null &&
                        widget.initialTransaction!.status.isPending
                    ? 'Confirm & Save'
                    : 'Save Transaction',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(TransactionType type, String label, Color activeColor) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : context.palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
