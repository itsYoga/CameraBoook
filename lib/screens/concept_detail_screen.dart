import 'package:flutter/material.dart';
import '../models/photography_concept.dart'; // 匯入模型
import '../widgets/interactive_demo.dart'; // 匯入互動 Demo Widget

// --- Concept Detail Screen ---
class ConceptDetailScreen extends StatelessWidget {
  final PhotographyConcept concept;

  const ConceptDetailScreen({super.key, required this.concept});

  @override
  Widget build(BuildContext context) {
    // Split the description into paragraphs based on double newline
    final List<String> paragraphs = concept.description
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return DefaultTabController(
      length: 2, // Two tabs: Explanation and Interactive Demo
      child: Scaffold(
        appBar: AppBar(
          title: Text(concept.name),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.description), text: '說明'),
              Tab(icon: Icon(Icons.touch_app), text: '互動體驗'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Explanation (Using ListView with Text and Image)
            ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: paragraphs.length, // 只需要根據段落數量來建立項目
              itemBuilder: (context, paragraphIndex) {
                final paragraph = paragraphs[paragraphIndex];
                final hasImage = paragraphIndex < concept.imageAssets.length;
                final imagePath = hasImage ? concept.imageAssets[paragraphIndex] : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        paragraph,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (hasImage && imagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Image.asset(imagePath),
                      ),
                    if (paragraphIndex < paragraphs.length - 1 && !hasImage) // 如果不是最後一段且沒有對應圖片，添加一些間距
                      const SizedBox(height: 16.0),
                  ],
                );
              },
            ),

            // Tab 2: Interactive Demo
            InteractiveDemo(concept: concept),
          ],
        ),
      ),
    );
  }
}