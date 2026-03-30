import 'dart:io';
import 'package:flutter/material.dart';

class UploadFileWidget extends StatefulWidget {
  final Function()? onTap;
  final File? selectedImage;
  final VoidCallback? onRemoveImage; 

  const UploadFileWidget({
    super.key, 
    required this.onTap, 
    this.selectedImage,
    this.onRemoveImage, 
  });

  @override
  State<UploadFileWidget> createState() => _UploadFileWidgetState();
}

class _UploadFileWidgetState extends State<UploadFileWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: widget.selectedImage == null
            ? const EdgeInsets.symmetric(vertical: 30)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF295AF5).withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: widget.selectedImage != null
            ? Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      widget.selectedImage!,
                      width: double.infinity,
                      height: 200, 
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 15,
                        ),
                        onPressed: () {
                          if (widget.onRemoveImage != null) {
                            widget.onRemoveImage!();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: const [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFF295AF5),
                    size: 30,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Subir Comprobante / Evidencia',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Toca para abrir cámara o galería',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
      ),
    );
  }
}