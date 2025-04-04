import 'package:flutter/material.dart';
import 'dart:ui' as ui; // For ImageFilter
import 'dart:io'; // For File
import 'package:image_picker/image_picker.dart'; // Import image_picker
import '../models/photography_concept.dart'; // 匯入模型
import 'dart:math'; // Not needed currently

// --- Interactive Demo Widget (Stateful) ---
class InteractiveDemo extends StatefulWidget {
  final PhotographyConcept concept;

  const InteractiveDemo({super.key, required this.concept});

  @override
  State<InteractiveDemo> createState() => _InteractiveDemoState();
}

class _InteractiveDemoState extends State<InteractiveDemo> {
  // Store current values of parameters (excluding SS)
  late Map<String, double> _currentValues;
  // Store the selected image file
  File? _selectedImageFile;
  // Image picker instance
  final ImagePicker _picker = ImagePicker();
  // Loading state for image picker
  bool _isLoadingImage = false;
  // Flag to show composition guide overlay
  bool _showCompositionGuide = true;

  // --- State for Shutter Speed Slider ---
  // Define standard shutter speeds
  final List<String> _shutterSpeeds = const [
    '30s', '15s', '8s', '4s', '2s', '1s',
    '1/2s', '1/4s', '1/8s', '1/15s', '1/30s', '1/60s', // Default index 11
    '1/125s', '1/250s', '1/500s', '1/1000s', '1/2000s', '1/4000s'
  ];
  // Currently selected shutter speed INDEX
  double _selectedShutterSpeedIndex = 11.0; // Default to index of '1/60s'

  @override
  void initState() {
    super.initState();
    // Initialize current values from the concept's parameters
    _currentValues = {
      for (var param in widget.concept.parameters)
        param.name: param.initialValue
    };
    // Set default shutter speed index if the concept is 'ss'
    if (widget.concept.id == 'ss') {
       int defaultIndex = _shutterSpeeds.indexOf('1/60s');
       _selectedShutterSpeedIndex = (defaultIndex != -1) ? defaultIndex.toDouble() : (_shutterSpeeds.length / 2.0);
    }
  }

  // --- Function to pick an image from gallery ---
  Future<void> _pickImage() async {
    if (!mounted) return;
    setState(() { _isLoadingImage = true; });
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (!mounted) return;
        setState(() { _selectedImageFile = File(pickedFile.path); });
      }
    } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('無法選擇圖片: $e')), );
    } finally {
       if (!mounted) return;
       setState(() { _isLoadingImage = false; });
    }
  }

  // --- Simulation Logic ---
  Widget _applyEffects(Widget imageChild) {
    double brightness = 1.0;
    double noiseOpacity = 0.0;
    double blurSigma = 0.0;
    Color colorOverlay = Colors.transparent;
    ColorFilter? colorFilter;
    double scale = 1.0;

    // --- ISO ---
    if (widget.concept.id == 'iso') {
      double isoValue = _currentValues['ISO'] ?? 100;
      brightness = 1.0 + (isoValue - 100) / 6400 * 0.5;
      noiseOpacity = (isoValue - 100) / 6400 * 0.15;
    }
    // --- Shutter Speed (Using Slider Index) ---
    else if (widget.concept.id == 'ss') {
       int currentIndex = _selectedShutterSpeedIndex.round(); // Get current index from slider
       // Ensure index is within bounds
       currentIndex = currentIndex.clamp(0, _shutterSpeeds.length - 1);

       // Find index of a reference speed (e.g., 1/60s)
       int referenceIndex = _shutterSpeeds.indexOf('1/60s');
       if (referenceIndex == -1) referenceIndex = _shutterSpeeds.length ~/ 2; // Fallback

       // Calculate difference in "stops" (each step is roughly one stop)
       double stops = (referenceIndex - currentIndex).toDouble();

       // Adjust brightness based on stops
       brightness = 1.0 + stops * 0.3; // Adjust multiplier as needed

       // Simulate motion blur for slower speeds (index < referenceIndex)
       if (currentIndex < referenceIndex) {
           // Increase blur more significantly for very slow speeds
           double blurFactor = (referenceIndex - currentIndex) * 0.5; // Adjust factor
           // Example: make blur increase faster for very slow speeds
           blurSigma = pow(blurFactor, 1.5).toDouble(); // Use power for faster increase
       } else {
           blurSigma = 0; // No blur for faster speeds
       }
       blurSigma = blurSigma.clamp(0.0, 15.0); // Clamp max blur
    }
    // --- Aperture ---
    else if (widget.concept.id == 'aperture') {
        double apertureValue = _currentValues['光圈 (大 -> 小)'] ?? 50;
        brightness = 1.0 + (50 - apertureValue) / 50 * 0.6;
        blurSigma = (50 - apertureValue) / 50 * 5.0;
        blurSigma = blurSigma > 0 ? blurSigma : 0;
    }
     // --- Exposure Compensation ---
    else if (widget.concept.id == 'ev') {
      double evValue = _currentValues['EV'] ?? 0;
      brightness = 1.0 + (evValue / 3.0 * 0.8);
    }
    // --- White Balance ---
    else if (widget.concept.id == 'wb') {
        double wbValue = _currentValues['色溫 (冷 -> 暖)'] ?? 50;
        if (wbValue < 50) { colorOverlay = Colors.blue.withOpacity((50 - wbValue) / 50 * 0.15); }
        else if (wbValue > 50) { colorOverlay = Colors.orange.withOpacity((wbValue - 50) / 50 * 0.15); }
    }
    // --- Color Grading ---
    else if (widget.concept.id == 'color') {
        double saturationValue = _currentValues['飽和度'] ?? 50;
        double contrastValue = _currentValues['對比度'] ?? 50;
        double filterValue = _currentValues['色調 (濾鏡)'] ?? 0;
        double sat = saturationValue / 50.0; double con = contrastValue / 50.0; double translate = 128 * (1.0 - con);
        final List<double> matrix = [ sat*con, 0, 0, 0, translate, 0, sat*con, 0, 0, translate, 0, 0, sat*con, 0, translate, 0, 0, 0, 1, 0, ];
        colorFilter = ColorFilter.matrix(matrix);
        if (filterValue == 1) { colorOverlay = Colors.brown.withOpacity(0.25); }
        else if (filterValue == 2) { colorOverlay = Colors.blue.withOpacity(0.15); }
        else if (filterValue == 3) { colorOverlay = Colors.orange.withOpacity(0.15); }
    }
    // --- Focal Length ---
    else if (widget.concept.id == 'focal_length') {
        double focalValue = _currentValues['焦距 (廣角 -> 長焦)'] ?? 50;
        scale = 0.5 + (focalValue / 100.0) * 1.5;
    }

    // --- Apply Effects ---
    Widget scaledChild = Transform.scale( scale: scale, child: imageChild, );
    Widget brightenedChild = ColorFiltered( colorFilter: ColorFilter.matrix([ brightness, 0, 0, 0, 0, 0, brightness, 0, 0, 0, 0, 0, brightness, 0, 0, 0, 0, 0, 1, 0, ]), child: scaledChild, );
    Widget colorGradedChild = colorFilter != null ? ColorFiltered(colorFilter: colorFilter, child: brightenedChild) : brightenedChild;
    Widget blurredChild = blurSigma > 0 ? ClipRect( child: Stack( fit: StackFit.expand, children: [ colorGradedChild, BackdropFilter( filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma), child: Container( color: Colors.black.withOpacity(0.01), ), ), ], ), ) : colorGradedChild;
    Widget finalChild = Stack( fit: StackFit.expand, children: [ blurredChild, if (noiseOpacity > 0) Opacity( opacity: noiseOpacity, child: Container( decoration: const BoxDecoration( image: DecorationImage( image: NetworkImage("https://static.vecteezy.com/system/resources/thumbnails/009/379/011/small/white-noise-texture-background-free-vector.jpg"), fit: BoxFit.cover, repeat: ImageRepeat.repeat ) ) ), ), if (colorOverlay != Colors.transparent) Container(color: colorOverlay), if (widget.concept.id == 'composition' && _showCompositionGuide && _selectedImageFile != null) CustomPaint( painter: RuleOfThirdsPainter(), child: Container(), ), ], );
    return ClipRect(child: finalChild);
  }


  @override
  Widget build(BuildContext context) {
    bool hasParameters = widget.concept.parameters.isNotEmpty;
    bool isShutterSpeed = widget.concept.id == 'ss';
    bool usesImagePicker = !['composition', 'histogram'].contains(widget.concept.id);

    Widget imagePreviewArea;
    // (Image Preview Area logic remains largely the same)
     if (_isLoadingImage) {
      imagePreviewArea = const Center(child: CircularProgressIndicator());
    } else if (_selectedImageFile != null) {
        imagePreviewArea = _applyEffects(
            Image.file( _selectedImageFile!, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) { return const Center(child: Text('無法載入圖片', style: TextStyle(color: Colors.red))); },
            ),
        );
    } else if (usesImagePicker || isShutterSpeed) {
      imagePreviewArea = Center(
          child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.photo_library_outlined, size: 50, color: Colors.grey),
              const SizedBox(height: 10),
              Text(isShutterSpeed ? "請選擇圖片以模擬快門速度" : "請選擇一張圖片進行測試"),
              const SizedBox(height: 10),
              ElevatedButton.icon( icon: const Icon(Icons.add_photo_alternate_outlined), label: const Text('選擇圖片'), onPressed: _pickImage, ),
            ],
          ),
        );
    } else {
       imagePreviewArea = Center(
          child: Padding( padding: const EdgeInsets.all(16.0),
            child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(widget.concept.icon, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text( widget.concept.id == 'composition' ? "此分頁將展示構圖輔助線。\n(選擇圖片後可查看效果)" : "此分頁將展示直方圖分析。\n(功能開發中)", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium, ),
                   if (widget.concept.id == 'composition') ...[ const SizedBox(height: 10), ElevatedButton.icon( icon: const Icon(Icons.add_photo_alternate_outlined), label: const Text('選擇圖片以查看輔助線'), onPressed: _pickImage, ), ]
                ]
            ),
          ),
       );
    }


    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Image Preview Area ---
          AspectRatio( aspectRatio: 3 / 2,
            child: Container( decoration: BoxDecoration( border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8.0), color: Colors.black.withOpacity(0.1), ), clipBehavior: Clip.antiAlias,
              child: imagePreviewArea,
            ),
          ),
          const SizedBox(height: 10),
          // --- Buttons Below Image ---
          Row( mainAxisAlignment: MainAxisAlignment.center, children: [
              if (_selectedImageFile != null && !_isLoadingImage && (usesImagePicker || isShutterSpeed)) TextButton.icon( icon: const Icon(Icons.refresh, size: 18), label: const Text('更換圖片'), onPressed: _pickImage, style: TextButton.styleFrom( foregroundColor: Theme.of(context).colorScheme.secondary, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),), ),
              if (_selectedImageFile != null && !_isLoadingImage && (usesImagePicker || isShutterSpeed) && widget.concept.id == 'composition') const SizedBox(width: 10),
              if (widget.concept.id == 'composition' && _selectedImageFile != null && !_isLoadingImage) TextButton.icon( icon: Icon(_showCompositionGuide ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18), label: Text(_showCompositionGuide ? '隱藏輔助線' : '顯示輔助線'), onPressed: () { setState(() { _showCompositionGuide = !_showCompositionGuide; }); }, style: TextButton.styleFrom( foregroundColor: Theme.of(context).colorScheme.secondary, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),), ),
            ],
          ),
          const SizedBox(height: 14.0),

          // --- Parameter Controls Area ---
          // Show Discrete Slider for Shutter Speed
          if (isShutterSpeed)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: IgnorePointer(
                 ignoring: _selectedImageFile == null, // Disable if no image
                 child: Opacity(
                    opacity: _selectedImageFile == null ? 0.5 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         // Display selected speed string
                         Text(
                           '快門速度: ${_shutterSpeeds[_selectedShutterSpeedIndex.round().clamp(0, _shutterSpeeds.length - 1)]}', // Display string
                           style: Theme.of(context).textTheme.titleMedium
                         ),
                         const SizedBox(height: 8),
                         // Discrete Slider
                         Slider(
                            value: _selectedShutterSpeedIndex,
                            min: 0,
                            max: (_shutterSpeeds.length - 1).toDouble(), // Max index
                            divisions: _shutterSpeeds.length - 1, // Number of steps
                            // Display the corresponding speed string in the label
                            label: _shutterSpeeds[_selectedShutterSpeedIndex.round().clamp(0, _shutterSpeeds.length - 1)],
                            onChanged: (double newIndex) {
                              setState(() {
                                _selectedShutterSpeedIndex = newIndex;
                              });
                            },
                         ),
                      ],
                    ),
                 ),
              ),
            ),

          // Show Sliders for other concepts with parameters
          if (hasParameters) // Removed !isShutterSpeed check here, as SS has no parameters now
            IgnorePointer(
              ignoring: _selectedImageFile == null && usesImagePicker,
              child: Opacity(
                opacity: (_selectedImageFile == null && usesImagePicker) ? 0.5 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Filter out parameters if concept is SS (should be empty anyway)
                  children: widget.concept.parameters.map((param) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text( '${param.name}: ${_currentValues[param.name]?.toStringAsFixed(param.divisions < 10 ? 1 : 0)}', style: Theme.of(context).textTheme.titleMedium, ),
                        Slider(
                          value: _currentValues[param.name] ?? param.initialValue, min: param.minValue, max: param.maxValue, divisions: param.divisions,
                          label: _currentValues[param.name]?.toStringAsFixed(param.divisions < 10 ? 1 : 0),
                          onChanged: (newValue) { setState(() { _currentValues[param.name] = newValue; }); },
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Custom Painter for Rule of Thirds Grid ---
class RuleOfThirdsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint() ..color = Colors.white.withOpacity(0.7) ..strokeWidth = 1.0;
    final double thirdWidth = size.width / 3; final double thirdHeight = size.height / 3;
    canvas.drawLine(Offset(thirdWidth, 0), Offset(thirdWidth, size.height), paint);
    canvas.drawLine(Offset(thirdWidth * 2, 0), Offset(thirdWidth * 2, size.height), paint);
    canvas.drawLine(Offset(0, thirdHeight), Offset(size.width, thirdHeight), paint);
    canvas.drawLine(Offset(0, thirdHeight * 2), Offset(size.width, thirdHeight * 2), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* --- Permissions Setup (Reminder) --- */
// Android: Add READ_EXTERNAL_STORAGE / READ_MEDIA_IMAGES to AndroidManifest.xml
// iOS: Add NSPhotoLibraryUsageDescription to Info.plist
