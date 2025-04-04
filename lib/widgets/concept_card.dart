import 'package:flutter/material.dart';
import '../models/photography_concept.dart'; // 匯入模型

// --- Custom Widget for Grid Item ---
class ConceptCard extends StatelessWidget {
  final PhotographyConcept concept;
  final VoidCallback onTap;

  const ConceptCard({
    super.key,
    required this.concept,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // Ensures ink splash stays within rounded corners
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(concept.icon, size: 48.0, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 12.0),
            Text(
              concept.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
