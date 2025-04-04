import 'package:flutter/material.dart'; // 需要 Icons
import '../models/photography_concept.dart'; // 匯入模型

// --- Sample Data ---
final List<PhotographyConcept> photographyConcepts = [
  // --- ISO 感光度 ---
  PhotographyConcept(
    id: 'iso',
    name: 'ISO 感光度',
    description:
        'ISO 代表相機感光元件對光的敏感度。較低的 ISO 適用於光線充足的環境，產生較少噪點的清晰影像。較高的 ISO 適用於低光環境，但會增加影像噪點。\n\n調整 ISO 會直接影響照片的亮度。過高的 ISO 會讓亮部過曝，且暗部充滿明顯的顆粒感。',
    icon: Icons.iso,
    parameters: [
      Parameter(name: 'ISO', initialValue: 100, minValue: 100, maxValue: 6400, divisions: 63),
    ],
    imageAssets: ['assets/images/ISO.webp'], // 添加圖片路徑
  ),
  // --- 快門速度 (SS) - 移除了 parameters ---
  PhotographyConcept(
    id: 'ss',
    name: '快門速度 (SS)',
    description:
        '快門速度是指相機快門開啟讓光線進入感光元件的時間長短。單位通常是秒或秒的分數。\n\n快的快門速度（例如 1/1000 秒）可以凝結快速移動的主體，適合拍攝運動或水滴。慢的快門速度（例如 1 秒或更長）會產生動態模糊效果，適合拍攝流水、星軌或在低光環境下增加曝光時間（需搭配三腳架）。它同樣影響照片亮度，快門越慢，進光量越多，照片越亮。',
    icon: Icons.shutter_speed,
    parameters: [], // <--- 不再需要參數，互動由 DropdownButton 控制
    imageAssets: ['assets/images/Shutter.gif'], // 添加圖片路徑
  ),
  // --- 光圈 (Aperture) ---
  PhotographyConcept(
    id: 'aperture',
    name: '光圈 (Aperture)',
    description:
        '光圈是鏡頭中控制光線進入相機的孔洞大小，通常用 f 值表示（例如 f/1.8, f/5.6, f/16）。\n\nf 值越小（例如 f/1.8），光圈孔徑越大，進入的光線越多，照片越亮，同時景深越淺（背景模糊效果明顯）。\nf 值越大（例如 f/16），光圈孔徑越小，進入的光線越少，照片越暗，但景深越深（前後景都相對清晰）。\n\n光圈是控制景深和進光量的關鍵因素。',
    icon: Icons.camera,
    parameters: [
      Parameter(name: '光圈 (大 -> 小)', initialValue: 50, minValue: 0, maxValue: 100),
    ],
    imageAssets: [], // 這個概念沒有圖片
  ),
  // --- 曝光補償 (EV) ---
  PhotographyConcept(
    id: 'ev',
    name: '曝光補償 (EV)',
    description:
        '曝光補償允許你手動調整相機建議的曝光值，讓照片變亮或變暗。\n\n當相機的自動測光不準確時（例如拍攝雪地或黑色物體），可以使用曝光補償進行修正。\n\n增加 EV (+) 會讓照片變亮，減少 EV (-) 會讓照片變暗。單位通常是級數（stops），每增加一級，曝光量加倍。',
    icon: Icons.exposure,
    parameters: [
      Parameter(name: 'EV', initialValue: 0, minValue: -3, maxValue: 3, divisions: 12),
    ],
    imageAssets: ['assets/images/EV.jpg'], // 添加圖片路徑
  ),
  // --- 白平衡 (WB) ---
  PhotographyConcept(
    id: 'wb',
    name: '白平衡 (WB)',
    description:
        '白平衡用於校正不同光源下的色彩偏差，確保照片中的白色物體呈現真實的白色。\n\n不同的光源有不同的色溫（例如燭光偏黃，陰天偏藍）。相機的自動白平衡 (AWB) 通常能應付大部分情況，但有時需要手動設定（如日光、陰天、鎢絲燈、螢光燈）或自訂 K 值來達到準確或創意的色彩效果。\n\n調整白平衡會改變照片的整體色調（偏冷或偏暖）。',
    icon: Icons.wb_sunny,
    parameters: [
      Parameter(name: '色溫 (冷 -> 暖)', initialValue: 50, minValue: 0, maxValue: 100),
    ],
    imageAssets: ['assets/images/WB.jpg'], // 添加圖片路徑
  ),
  // --- 調色 (Color Grading) ---
    PhotographyConcept(
    id: 'color',
    name: '調色 (Color Grading)',
    description:
        '調色是在照片拍攝完成後，對色彩進行調整以達到特定風格或氛圍的過程。這不同於白平衡校正色彩偏差，調色更側重於藝術表達。\n\n可以調整飽和度（色彩的鮮豔程度）、對比度（明暗反差）、特定顏色的色相和明度等。',
    icon: Icons.palette,
    parameters: [
      Parameter(name: '飽和度', initialValue: 50, minValue: 0, maxValue: 100),
      Parameter(name: '對比度', initialValue: 50, minValue: 0, maxValue: 100),
      Parameter(name: '色調 (濾鏡)', initialValue: 0, minValue: 0, maxValue: 3, divisions: 3),
    ],
    imageAssets: [], // 這個概念沒有圖片
  ),
  // --- 構圖法則 ---
  PhotographyConcept(
    id: 'composition',
    name: '構圖法則',
    description:
        '構圖是安排畫面元素的藝術，引導觀眾視線並表達主題。\n\n常見法則：\n* 三分法 (Rule of Thirds): 將畫面用兩條水平線和兩條垂直線分成九宮格，將重要元素放在線條或交叉點上。\n* 引導線 (Leading Lines): 利用畫面中的線條（道路、河流、欄杆等）引導觀眾的目光到主體。\n* 對稱 (Symmetry): 利用對稱元素創造平衡、和諧或莊重的感覺。\n* 框架構圖 (Framing): 利用前景元素（門框、窗戶、樹枝等）包圍主體，增加畫面層次和深度。\n\n熟悉這些法則並靈活運用，可以讓你的照片更具吸引力。',
    icon: Icons.grid_on,
    parameters: [],
    imageAssets: ['assets/images/composition.jpg'], // 添加圖片路徑
  ),
  // --- 焦距 ---
  PhotographyConcept(
    id: 'focal_length',
    name: '焦距',
    description:
        '焦距是鏡頭光學中心到感光元件的距離，單位是毫米 (mm)。它決定了鏡頭的視角範圍和放大倍率。\n\n* 廣角鏡頭 (Short Focal Length, e.g., <35mm): 視角寬廣，能容納更多景物，常用於風景、建築攝影。可能產生桶狀變形。\n* 標準鏡頭 (Standard Focal Length, e.g., ~50mm): 視角接近人眼所見，變形較小，用途廣泛。\n* 長焦鏡頭 (Long Focal Length, e.g., >70mm): 視角狹窄，能「拉近」遠處物體，產生空間壓縮感（背景與主體距離看似縮短），常用於人像、運動、野生動物攝影。\n\n焦距也影響景深，通常長焦鏡頭更容易獲得淺景深效果。',
    icon: Icons.camera_roll_outlined,
    parameters: [
      Parameter(name: '焦距 (廣角 -> 長焦)', initialValue: 50, minValue: 0, maxValue: 100),
    ],
    imageAssets: ['assets/images/focal.jpeg'], // 添加圖片路徑
  ),
  // --- 直方圖 ---
  //PhotographyConcept(
    //id: 'histogram',
  // name: '直方圖',
  // description:
  //      '直方圖是顯示照片像素亮度分佈的圖表。橫軸從左到右代表從純黑到純白的亮度級別，縱軸代表具有該亮度的像素數量。\n\n* 圖形偏左: 表示畫面整體偏暗，可能有曝光不足的風險。\n* 圖形偏右: 表示畫面整體偏亮，可能有曝光過度的風險（高光溢出）。\n* 圖形集中在中間: 表示畫面反差較低。\n* 圖形分佈均勻或呈山峰狀: 通常表示曝光比較均衡（但不絕對）。\n\n直方圖是判斷曝光是否準確的重要客觀依據，比單純看螢幕預覽更可靠，尤其在戶外強光下。學會判讀直方圖有助於避免損失暗部或亮部細節。',
  //  icon: Icons.bar_chart,
  //  parameters: [],
  //  imageAssets: [], // 這個概念沒有圖片
  //),
];