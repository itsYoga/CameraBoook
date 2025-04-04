import 'package:flutter/material.dart';
import '../data/sample_data.dart'; // 匯入範例資料
import '../widgets/concept_card.dart'; // 匯入 ConceptCard Widget
import 'concept_detail_screen.dart'; // 匯入細節畫面
// import '../widgets/aperture_ring_transition.dart'; // <--- 移除不再需要的匯入

// --- Home Screen (Look Book) ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('攝影知識 Camera Knowledge'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0, // Make items square
        ),
        itemCount: photographyConcepts.length,
        itemBuilder: (context, index) {
          final concept = photographyConcepts[index];
          return ConceptCard(
            concept: concept,
            onTap: () {
              // --- 使用 MaterialPageRoute 進行導航 (移除動畫) ---
              Navigator.push(
                context,
                MaterialPageRoute( // <--- 改回使用 MaterialPageRoute
                  builder: (context) => ConceptDetailScreen(concept: concept),
                ),
              );
              // --- 原本使用 SvgShutterPageRoute 的程式碼 ---
              // Navigator.push(
              //   context,
              //   SvgShutterPageRoute( // <--- 原本使用自訂路由
              //     builder: (context) => ConceptDetailScreen(concept: concept),
              //   ),
              // );
            },
          );
        },
      ),
    );
  }
}
