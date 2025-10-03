import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rive/rive.dart';

class HabitPhotoPicker extends StatefulWidget {
  const HabitPhotoPicker({
    super.key,
    this.imagePath,
    required this.onImageSelected,
    this.isCompletedToday = false,
    this.animationScale = 1.0,
  });

  final String? imagePath;
  final Function(String?) onImageSelected;
  final bool isCompletedToday;
  final double animationScale;

  @override
  State<HabitPhotoPicker> createState() => _HabitPhotoPickerState();
}

class _HabitPhotoPickerState extends State<HabitPhotoPicker> {
  StateMachineController? _controller;

  @override
  void didUpdateWidget(HabitPhotoPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Control animation based on completion status
    if (widget.isCompletedToday != oldWidget.isCompletedToday) {
      _controller?.isActive = widget.isCompletedToday;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (photo != null) {
                    widget.onImageSelected(photo.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (photo != null) {
                    widget.onImageSelected(photo.path);
                  }
                },
              ),
              if (widget.imagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onImageSelected(null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: SizedBox(
        width: 120 * widget.animationScale, // Allow space for scaled animation
        height: 120 * widget.animationScale,
        child: Stack(
          clipBehavior: Clip.none, // Allow animation to overflow the stack
          alignment: Alignment.center,
          children: [
            // Photo circle (bottom layer)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: widget.imagePath != null
                    ? Image.file(
                        File(widget.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),
            // Animation overlay (top layer) - always visible, plays when completed
            SizedBox(
              width: 120 * widget.animationScale,
              height: 120 * widget.animationScale,
              child: Transform.translate(
                offset: const Offset(2, 5), // Shift down by 3 pixels
                child: RiveAnimation.asset(
                  'assets/animations/CircleLoopOne.riv',
                  fit: BoxFit.contain,
                  onInit: (artboard) {
                    final controller = StateMachineController.fromArtboard(
                      artboard,
                      'State Machine 1',
                    );
                    if (controller != null) {
                      artboard.addController(controller);
                      _controller = controller;
                      // Only play animation when completed
                      _controller?.isActive = widget.isCompletedToday;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.add_a_photo,
      size: 50,
      color: Colors.grey[600],
    );
  }
}
