import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/account.dart';
import '../../../../core/theme/app_colors.dart';

class CardScannerModal extends StatefulWidget {
  final Function(Account account) onCardScanned;

  const CardScannerModal({
    super.key,
    required this.onCardScanned,
  });

  @override
  State<CardScannerModal> createState() => _CardScannerModalState();
}

class _CardScannerModalState extends State<CardScannerModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  String _statusText = 'Align your card inside the frame';

  // Sample cards for realistic instant OCR test & simulation
  final List<Map<String, dynamic>> _demoCards = [
    {
      'provider': 'gcb',
      'bankName': 'GCB Bank Ghana',
      'cardName': 'GCB Visa Debit',
      'number': '4123 8812 9014 5502',
      'expiry': '08/29',
      'holder': 'KWAME MENSAH',
      'balance': 1500.00,
      'gradient': const [Color(0xFFD97706), Color(0xFF1E293B)],
    },
    {
      'provider': 'ecobank',
      'bankName': 'Ecobank Ghana',
      'cardName': 'Ecobank Mastercard',
      'number': '5399 2140 7718 3319',
      'expiry': '11/27',
      'holder': 'AMA SERWAA',
      'balance': 850.00,
      'gradient': const [Color(0xFF0284C7), Color(0xFF0C4A6E)],
    },
    {
      'provider': 'calbank',
      'bankName': 'CalBank Ghana',
      'cardName': 'CalBank Current Card',
      'number': '4012 5590 1400 7210',
      'expiry': '03/28',
      'holder': 'KOFI ADDO',
      'balance': 620.00,
      'gradient': const [Color(0xFF1D4ED8), Color(0xFF0F172A)],
    },
    {
      'provider': 'stanbic',
      'bankName': 'Stanbic Bank',
      'cardName': 'Stanbic Everyday Card',
      'number': '4505 1923 8810 4091',
      'expiry': '05/29',
      'holder': 'ABENA OSEI',
      'balance': 2100.00,
      'gradient': const [Color(0xFF2563EB), Color(0xFF1E3A8A)],
    },
    {
      'provider': 'absa',
      'bankName': 'Absa Bank Ghana',
      'cardName': 'Absa Premier Card',
      'number': '4210 9941 3320 8812',
      'expiry': '12/28',
      'holder': 'YAW BOATENG',
      'balance': 3400.00,
      'gradient': const [Color(0xFFBE123C), Color(0xFF881337)],
    },
    {
      'provider': 'fidelity',
      'bankName': 'Fidelity Bank',
      'cardName': 'Fidelity Smart Card',
      'number': '4028 3491 0021 6599',
      'expiry': '09/27',
      'holder': 'EFUA MANSA',
      'balance': 980.00,
      'gradient': const [Color(0xFFEA580C), Color(0xFF1E293B)],
    },
  ];

  int _selectedDemoIndex = 0;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _triggerScan([Map<String, dynamic>? selectedCard]) async {
    final card = selectedCard ?? _demoCards[_selectedDemoIndex];

    setState(() {
      _isProcessing = true;
      _statusText = 'Analyzing frame with OCR engine...';
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _statusText = 'Detecting card issuer and 16-digit PAN...');

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _statusText = 'Extracting expiration date and holder name...');

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _statusText = 'Card successfully captured!';
    });

    _showResultDialog(card);
  }

  void _showResultDialog(Map<String, dynamic> card) {
    final palette = context.palette;
    final balanceController =
        TextEditingController(text: card['balance'].toStringAsFixed(2));
    final nameController = TextEditingController(text: card['cardName']);

    // Mask card digits for display
    final rawNumber = card['number'] as String;
    final masked =
        '${rawNumber.substring(0, 4)}*******${rawNumber.substring(rawNumber.length - 4)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: palette.border, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle pill
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: const Color(0xFF10B981), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Card Captured via OCR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Captured Card Realistic Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: card['gradient'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (card['bankName'] as String).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'OCR SCANNED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    rawNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 15,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CARDHOLDER',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            card['holder'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'EXPIRES',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            card['expiry'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card Account Name field
            TextField(
              controller: nameController,
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                labelText: 'Account Nickname',
                labelStyle: TextStyle(color: palette.textSecondary),
                filled: true,
                fillColor: palette.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: palette.border),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Current Balance field
            TextField(
              controller: balanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                labelText: 'Current Balance (GHS)',
                labelStyle: TextStyle(color: palette.textSecondary),
                filled: true,
                fillColor: palette.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: palette.border),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Confirm Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final bal =
                      double.tryParse(balanceController.text.trim()) ?? 0.0;
                  final newAccount = Account(
                    id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim().isEmpty
                        ? card['cardName']
                        : nameController.text.trim(),
                    provider: card['provider'],
                    maskedNumber: masked,
                    lastBalance: bal,
                    lastBalanceDate: DateTime.now(),
                  );

                  Navigator.of(ctx).pop(); // Close bottom sheet
                  Navigator.of(context).pop(); // Close scanner
                  widget.onCardScanned(newAccount);
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add to My Wallets',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.85;
    final cardHeight = cardWidth / 1.586; // Standard ISO/IEC 7810 ID-1 aspect ratio
    final currentDemo = _demoCards[_selectedDemoIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Card OCR Scanner',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _isFlashOn ? const Color(0xFFFFB300) : Colors.white70,
              size: 24,
            ),
            onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Viewfinder Camera Reticle Area
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simulated Camera Feed (Subtle animated backdrop)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF0F172A),
                    child: Center(
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 160,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Live Card Preview in Viewfinder
                Center(
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: currentDemo['gradient'] as List<Color>,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (currentDemo['bankName'] as String).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currentDemo['number'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 16,
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentDemo['holder'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              currentDemo['expiry'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Corner Reticles & Viewfinder Mask
                Center(
                  child: Container(
                    width: cardWidth + 8,
                    height: cardHeight + 8,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isProcessing
                            ? const Color(0xFF10B981)
                            : const Color(0xFF38BDF8),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                // Animated Sweeping Laser Line
                AnimatedBuilder(
                  animation: _laserController,
                  builder: (context, child) {
                    final topOffset =
                        -cardHeight / 2 + (_laserController.value * cardHeight);
                    return Transform.translate(
                      offset: Offset(0, topOffset),
                      child: Container(
                        width: cardWidth - 10,
                        height: 2.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              _isProcessing
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF38BDF8),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isProcessing
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF38BDF8))
                                  .withOpacity(0.8),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Status Message Banner
                Positioned(
                  top: 24,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isProcessing
                            ? const Color(0xFF10B981)
                            : Colors.white24,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isProcessing)
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(right: 8),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        Text(
                          _statusText,
                          style: TextStyle(
                            color: _isProcessing
                                ? const Color(0xFF10B981)
                                : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Controls & Quick Card Selection
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick Select Card Template Chips
                Row(
                  children: [
                    const Icon(Icons.credit_card_rounded,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'TARGET CARD TO SCAN',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_demoCards.length, (idx) {
                      final c = _demoCards[idx];
                      final isSelected = _selectedDemoIndex == idx;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            c['bankName'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white12,
                            ),
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedDemoIndex = idx);
                          },
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 18),

                // Shutter Capture & Scan Button
                GestureDetector(
                  onTap: _isProcessing ? null : () => _triggerScan(),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.5),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isProcessing
                            ? const Color(0xFF10B981)
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isProcessing
                            ? Icons.check_rounded
                            : Icons.document_scanner_rounded,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tap Shutter to Capture & Scan Card',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
