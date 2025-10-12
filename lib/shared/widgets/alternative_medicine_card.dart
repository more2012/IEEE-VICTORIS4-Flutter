import 'package:awan/models/alternative_medicine_model.dart';
import 'package:flutter/material.dart';

class AlternativeMedicineCard extends StatelessWidget {
  final AlternativeMedicine alternative;
  final VoidCallback onAddPressed;

  const AlternativeMedicineCard({
    super.key,
    required this.alternative,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with medicine name and similarity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  alternative.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSimilarityColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${alternative.similarityPercentage.toInt()}% match',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Active ingredient and dosage
          Text(
            'Active: ${alternative.activeIngredient}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (alternative.dosage.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Dosage: ${alternative.dosage}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Manufacturer and price
          Row(
            children: [
              Expanded(
                child: Text(
                  'By: ${alternative.manufacturer}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ),
              Text(
                'EGP ${alternative.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF007AFF),
                ),
              ),
            ],
          ),

          if (alternative.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              alternative.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8E93),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 12),

          // Availability and Add button
          Row(
            children: [
              // Availability indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAvailabilityColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alternative.availability,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),

              const Spacer(),

              // Add to medicines button
              ElevatedButton(
                onPressed: onAddPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                ),
                child: const Text(
                  'Add Medicine',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Side effects (expandable)
          if (alternative.sideEffects.isNotEmpty) ...[
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text(
                'Side Effects',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8E8E93),
                ),
              ),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: alternative.sideEffects.map((effect) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 6,
                                color: Color(0xFF8E8E93),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                effect,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            ],
                          ),
                        )
                    ).toList(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getSimilarityColor() {
    if (alternative.similarityPercentage >= 90) {
      return Colors.green;
    } else if (alternative.similarityPercentage >= 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getAvailabilityColor() {
    switch (alternative.availability.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'limited':
        return Colors.orange;
      case 'out of stock':
        return Colors.red;
      default:
        return const Color(0xFF8E8E93);
    }
  }
}