import 'package:flutter/material.dart';
import '../../../../core/models/account.dart';
import '../../../../core/theme/app_colors.dart';
import 'account_card.dart';

class SlideableAccountCard extends StatefulWidget {
  final Account account;
  final VoidCallback onTap;
  final VoidCallback onAdjustBalance;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const SlideableAccountCard({
    super.key,
    required this.account,
    required this.onTap,
    required this.onAdjustBalance,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  State<SlideableAccountCard> createState() => _SlideableAccountCardState();
}

class _SlideableAccountCardState extends State<SlideableAccountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragOffset = 0.0;

  static const double _maxLeftOffset = -140.0; // Reveals Adjust & Delete
  static const double _maxRightOffset = 90.0; // Reveals Set Default

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _dragOffset = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _animation = Tween<double>(begin: _dragOffset, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.reset();
    _controller.forward();
  }

  void _close() {
    if (_dragOffset != 0.0) {
      _animateTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          // Background Action Buttons
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: palette.surface,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Action: Set as Default
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _buildActionButton(
                      icon: widget.account.isDefault
                          ? Icons.check_circle_rounded
                          : Icons.star_rounded,
                      label: widget.account.isDefault ? 'Default' : 'Set Default',
                      bgColor: const Color(0xFF10B981),
                      onTap: () {
                        _close();
                        widget.onSetDefault();
                      },
                    ),
                  ),

                  // Right Actions: Adjust Balance & Delete
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          icon: Icons.tune_rounded,
                          label: 'Adjust',
                          bgColor: const Color(0xFF2563EB),
                          onTap: () {
                            _close();
                            widget.onAdjustBalance();
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete',
                          bgColor: const Color(0xFFEF4444),
                          onTap: () {
                            _close();
                            widget.onDelete();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sliding Foreground Card
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragOffset += details.primaryDelta!;
                if (_dragOffset < _maxLeftOffset) {
                  _dragOffset = _maxLeftOffset;
                } else if (_dragOffset > _maxRightOffset) {
                  _dragOffset = _maxRightOffset;
                }
              });
            },
            onHorizontalDragEnd: (details) {
              if (_dragOffset < -50) {
                _animateTo(_maxLeftOffset);
              } else if (_dragOffset > 40) {
                _animateTo(_maxRightOffset);
              } else {
                _animateTo(0.0);
              }
            },
            child: Transform.translate(
              offset: Offset(_dragOffset, 0),
              child: AccountCard(
                account: widget.account,
                onTap: () {
                  if (_dragOffset != 0.0) {
                    _close();
                  } else {
                    widget.onTap();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 58,
          height: 74,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
