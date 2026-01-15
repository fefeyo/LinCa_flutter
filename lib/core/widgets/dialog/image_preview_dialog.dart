import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImagePreviewDialog extends StatelessWidget {
  const ImagePreviewDialog({
    super.key,
    required this.imageUrl,
    required this.isEditable,
    this.onEdit,
    this.onDelete,
  });

  final bool isEditable;
  final String imageUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Center(
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  minScale: 1,
                  maxScale: 5,
                  child: FittedBox(
                    fit: BoxFit.contain, // ← Twitter と同じ振る舞い
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black45,
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    fixedSize: const Size(48, 48),
                  ),
                  onPressed: () => context.router.pop(),
                ),
              ),
              if (isEditable)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      fixedSize: const Size(48, 48),
                    ),
                    onPressed: () {
                      onDelete?.call();
                      context.router.pop();
                    },
                  ),
                ),
              if (isEditable)
                Positioned(
                  top: 16,
                  right: 78,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      fixedSize: const Size(48, 48),
                    ),
                    onPressed: () {
                      onEdit?.call();
                      context.router.pop();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String imageUrl,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) => ImagePreviewDialog(
        imageUrl: imageUrl,
        isEditable: false,
      ),
    );
  }

  static Future<bool?> showEditable({
    required BuildContext context,
    required String imageUrl,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) => ImagePreviewDialog(
        imageUrl: imageUrl,
        isEditable: true,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}
