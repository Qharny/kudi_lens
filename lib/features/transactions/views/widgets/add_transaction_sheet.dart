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
      // Updating existing / confirming pending
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
      // Adding new manual transaction
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

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 16,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: AppColors.cardBorderDark,
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 16),

            // Segmented Transaction Type Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
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
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorderDark),
              ),
              child: Row(
                children: [
                  const Text(
                    'GHS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      autofocus: widget.initialTransaction == null,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryDark,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: AppColors.textMutedDark,
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
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: CategoryItem.defaultCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                            ? cat.color.withOpacity(0.25)
                            : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? cat.color : AppColors.cardBorderDark,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cat.icon,
                            size: 16,
                            color: isSelected ? cat.color : AppColors.textSecondaryDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textSecondaryDark,
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
                // Account dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account / Wallet',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorderDark),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedAccountId,
                            isExpanded: true,
                            dropdownColor: AppColors.cardDark,
                            style: const TextStyle(
                              color: AppColors.textPrimaryDark,
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

                // Date Picker Button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryDark,
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
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBorderDark),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: AppColors.textSecondaryDark,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormatter.formatShortDate(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimaryDark,
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
              style: const TextStyle(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                labelText: 'Merchant / Recipient (Optional)',
                labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cardBorderDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cardBorderDark),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Note input
            TextField(
              controller: _noteController,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cardBorderDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cardBorderDark),
                ),
              ),
            ),

            // Raw Alert reference box if this was pre-filled from bank alert
            if (widget.initialTransaction?.rawMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorderDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.mark_email_read_rounded,
                            size: 14, color: AppColors.primaryLight),
                        SizedBox(width: 6),
                        Text(
                          'Original Alert Message',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.initialTransaction!.rawMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Create learned rule toggle if relevant
            if (widget.initialTransaction?.narration != null) ...[
              const SizedBox(height: 10),
              CheckboxListTile(
                value: _createRule,
                onChanged: (val) => setState(() => _createRule = val ?? false),
                title: Text(
                  'Auto-categorize future alerts with "${widget.initialTransaction!.narration}"',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
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
              color: isSelected ? Colors.white : AppColors.textSecondaryDark,
            ),
          ),
        ),
      ),
    );
  }
}
