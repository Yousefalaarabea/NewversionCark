import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auth_cubit.dart';

///DONE

// Widget to display and upload ID images in the profile section.
class IdImageWidgets extends StatelessWidget {
  const IdImageWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();
        log("builder called when state ${state.runtimeType}");

        return InkWell(
          onTap: () {
            authCubit.uploadIdImage(isFront: true);
          },

          child: SizedBox(
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: authCubit.idImagePath.isNotEmpty
                  ? ClipRRect(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(authCubit.idImagePath),
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
          ),
        );
      },

      buildWhen: (previous, current) {
        return current is UploadIdImageLoading ||
            current is UploadIdImageSuccess ||
            current is UploadIdImageFailure;
      },
    );
  }
}
