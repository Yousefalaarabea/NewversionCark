import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';

/// DONE
class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          current is UploadProfileScreenImageSuccess ||
          current is UploadProfileScreenImageFailure,

      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();
        return Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Profile picture
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                backgroundImage: authCubit.profileImage.isNotEmpty
                    ? FileImage(File(authCubit.profileImage))
                    : null,
                child: authCubit.profileImage.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),

              // Edit button
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.onSecondary,
                child: IconButton(
                  icon: Icon(Icons.edit,
                      color: Theme.of(context).colorScheme.onPrimary, size: 18),
                  onPressed: () {
                    authCubit.uploadProfileImage();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
