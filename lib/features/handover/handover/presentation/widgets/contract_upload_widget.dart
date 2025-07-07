import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../config/themes/app_colors.dart';
import '../cubits/contract_upload_cubit.dart';

class ContractUploadWidget extends StatelessWidget {
  const ContractUploadWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContractUploadCubit, ContractUploadState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Signed Contract',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            
            // Contract image display
            if (state is ContractUploadSuccess)
              _buildContractImagePreview(context, state.imagePath)
            else
              _buildUploadButton(context, state),
            
            // Error message
            if (state is ContractUploadFailure)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.error,
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContractImagePreview(BuildContext context, String imagePath) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => context.read<ContractUploadCubit>().clearContractImage(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, ContractUploadState state) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gray.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
        color: AppColors.white,
      ),
      child: state is ContractUploadLoading
          ? const Center(child: CircularProgressIndicator())
          : InkWell(
              onTap: () {
                final contractUploadCubit = context.read<ContractUploadCubit>();
                contractUploadCubit.takeContractImageFromCamera();
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 40,
                    color: AppColors.gray,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to capture contract image',
                    style: TextStyle(
                      color: AppColors.gray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 