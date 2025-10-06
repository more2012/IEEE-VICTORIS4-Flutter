import 'package:flutter/material.dart';

class HorizontalActionButtons extends StatelessWidget {
  final VoidCallback onAddMedicinePressed;
  final VoidCallback onScanMedicinePressed;
  final VoidCallback onFindAlternativePressed;

  const HorizontalActionButtons({
    Key? key,
    required this.onAddMedicinePressed,
    required this.onScanMedicinePressed,
    required this.onFindAlternativePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _ActionButton(
              icon: Icons.add,
              text: 'Add New Med',
              onPressed: onAddMedicinePressed,
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.qr_code_scanner,
              text: 'Scan Medicine',
              onPressed: onScanMedicinePressed,
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.search,
              text: 'Find Alt',
              onPressed: onFindAlternativePressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF007AFF).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}