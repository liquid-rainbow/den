import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/den_colors.dart';

class ImageCropAdjustDialog extends StatefulWidget {
  final XFile imageFile;

  const ImageCropAdjustDialog({super.key, required this.imageFile});

  static Future<XFile?> show(BuildContext context, XFile imageFile) {
    return showDialog<XFile>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ImageCropAdjustDialog(imageFile: imageFile),
    );
  }

  @override
  State<ImageCropAdjustDialog> createState() => _ImageCropAdjustDialogState();
}

class _ImageCropAdjustDialogState extends State<ImageCropAdjustDialog> {
  final TransformationController _transformController = TransformationController();
  double _rotation = 0;
  double _selectedAspectRatio = 0; // 0 = Free / Natural, 1.0 = Square, 4/5 = Portrait

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: const Color(0xFF141416),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: double.infinity,
          height: screenSize.height * 0.78,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                    const Text(
                      'Crop & Adjust',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.rotate_right, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _rotation = (_rotation + 90) % 360;
                        });
                      },
                      tooltip: 'Rotate 90°',
                    ),
                  ],
                ),
              ),

              // Aspect Ratio Pills Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    _buildAspectChip('Full / Free', 0),
                    const SizedBox(width: 8),
                    _buildAspectChip('Portrait (4:5)', 4 / 5),
                    const SizedBox(width: 8),
                    _buildAspectChip('Square (1:1)', 1.0),
                    const SizedBox(width: 8),
                    _buildAspectChip('Story (9:16)', 9 / 16),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Interactive Image Frame Workspace
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Zoomable Image
                      RotatedBox(
                        quarterTurns: (_rotation / 90).round(),
                        child: InteractiveViewer(
                          transformationController: _transformController,
                          minScale: 0.3,
                          maxScale: 6.0,
                          boundaryMargin: const EdgeInsets.all(120),
                          child: Center(
                            child: Image.file(
                              File(widget.imageFile.path),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 48)),
                            ),
                          ),
                        ),
                      ),

                      // Framing Overlay Guides (Full area or selected aspect ratio)
                      IgnorePointer(
                        child: _selectedAspectRatio > 0
                            ? AspectRatio(
                                aspectRatio: _selectedAspectRatio,
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: _buildGridLines(),
                                ),
                              )
                            : Container(
                                margin: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: _buildGridLines(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Instruction Caption
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Pinch to zoom • Drag to frame image',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),

              // Bottom Actions: Reset & Done
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _transformController.value = Matrix4.identity();
                          setState(() {
                            _rotation = 0;
                            _selectedAspectRatio = 0;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(widget.imageFile);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DenColors.primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Done / Use Photo',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAspectChip(String label, double ratio) {
    final isSelected = (_selectedAspectRatio - ratio).abs() < 0.01;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAspectRatio = ratio;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? DenColors.primary : const Color(0xFF26262B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? DenColors.primary : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildGridLines() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: Container(decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.2)), bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
              Expanded(child: Container(decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.2)), bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
              Expanded(child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Container(decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.2)), bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
              Expanded(child: Container(decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.2)), bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
              Expanded(child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Container(decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
              Expanded(child: Container(decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
              Expanded(child: Container()),
            ],
          ),
        ),
      ],
    );
  }
}
