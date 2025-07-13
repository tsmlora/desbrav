import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

class ImagePickerWidget extends StatelessWidget {
  final Function(File) onImageSelected;
  final VoidCallback? onRemoveImage;
  final bool showRemoveOption;
  final String? currentImageUrl;

  const ImagePickerWidget({
    Key? key,
    required this.onImageSelected,
    this.onRemoveImage,
    this.showRemoveOption = false,
    this.currentImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.dividerColor,
              style: BorderStyle.solid,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'photo_camera',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Foto do Perfil',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showImageSourceDialog(context),
                      icon: CustomIconWidget(
                        iconName: 'add_a_photo',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 18,
                      ),
                      label: Text('Escolher Foto'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        side: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  if (showRemoveOption && onRemoveImage != null) ...[
                    SizedBox(width: 3.w),
                    OutlinedButton.icon(
                      onPressed: () => _showRemoveConfirmation(context),
                      icon: CustomIconWidget(
                        iconName: 'delete_outline',
                        color: AppTheme.errorLight,
                        size: 18,
                      ),
                      label: Text('Remover'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        side: BorderSide(color: AppTheme.errorLight),
                        foregroundColor: AppTheme.errorLight,
                      ),
                    ),
                  ],
                ],
              ),
              if (currentImageUrl != null) ...[
                SizedBox(height: 2.h),
                Text(
                  'Foto atual será substituída',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                // Handle bar
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 44.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Column(
                    children: [
                      Text(
                        'Escolher Foto',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // Camera option
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'photo_camera',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        title: Text('Câmera'),
                        subtitle: Text('Tirar uma nova foto'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),

                      // Gallery option
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.secondary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'photo_library',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 24,
                          ),
                        ),
                        title: Text('Galeria'),
                        subtitle: Text('Escolher da galeria'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRemoveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remover Foto'),
          content: Text('Tem certeza que deseja remover sua foto de perfil?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRemoveImage?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorLight,
              ),
              child: Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check and request permissions
      bool permissionGranted = await _checkAndRequestPermissions(source);

      if (!permissionGranted) {
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        onImageSelected(imageFile);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<bool> _checkAndRequestPermissions(ImageSource source) async {
    Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      // For gallery access on different platforms
      if (Platform.isAndroid) {
        permission = Permission.storage;
      } else {
        permission = Permission.photos;
      }
    }

    PermissionStatus status = await permission.status;

    if (status.isDenied) {
      status = await permission.request();
    }

    return status.isGranted;
  }
}
