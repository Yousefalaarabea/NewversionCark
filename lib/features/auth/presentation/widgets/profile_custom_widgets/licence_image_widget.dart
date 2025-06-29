import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../cubits/auth_cubit.dart';

///DONE
class LicenceImageWidget extends StatelessWidget {
  const LicenceImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();
        log("builder called when state ${state.runtimeType}");
        return InkWell(
          onTap: () {
            authCubit.uploadLicenceImage();
          },
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: authCubit.licenceImagePath.isNotEmpty
                      ? ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(authCubit.licenceImagePath),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.2),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                if (state is UploadLicenceImageFailure) ...[
                  Text(
                    state.error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      buildWhen: (previous, current) {
        return current is UploadLicenceImageLoading ||
            current is UploadLicenceImageSuccess ||
            current is UploadLicenceImageFailure;
      },
    );
  }
}
