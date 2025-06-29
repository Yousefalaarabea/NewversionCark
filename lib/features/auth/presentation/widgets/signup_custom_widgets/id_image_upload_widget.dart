import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/assets_manager.dart';
import '../../cubits/auth_cubit.dart';


class IdImageUploadWidget extends StatelessWidget {
  const IdImageUploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        return current is UploadIdImageLoading ||
            current is UploadIdImageSuccess ||
            current is UploadIdImageFailure;
      },
      builder: (context, state) {
        final authCubit = context.watch<AuthCubit>();
        final frontImage = authCubit.frontIdImage;
        final backImage = authCubit.backIdImage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload National ID',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            Column(
              children: [
                _buildImagePicker(
                  context: context,
                  label: 'Front Side',
                  imageFile: frontImage,
                  exampleImagePath: AssetsManager.frontSideId,
                  onTap: () => authCubit.uploadIdImage(isFront: true),
                  isLoading: state is UploadIdImageLoading,
                ),
                SizedBox(height: 24.h),
                _buildImagePicker(
                  context: context,
                  label: 'Back Side',
                  imageFile: backImage,
                  exampleImagePath: AssetsManager.backSideId,
                  onTap: () => authCubit.uploadIdImage(isFront: false),
                  isLoading: state is UploadIdImageLoading,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePicker({
    required BuildContext context,
    required String label,
    required File? imageFile,
    required String exampleImagePath,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Column(
        children: [
          Container(
            height: 180.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade400),
              image: imageFile != null
                  ? DecorationImage(
                      image: FileImage(imageFile),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: AssetImage(exampleImagePath),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
            ),
            child: (isLoading)
                ? const Center(child: CircularProgressIndicator())
                : (imageFile == null)
                    ? Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                      )
                    : null,
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: imageFile != null ? Colors.green : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
