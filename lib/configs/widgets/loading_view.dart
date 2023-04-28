import 'package:flutter/material.dart';
import 'package:zechat/configs/constants/app_colors.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.themeColor,
        ),
      ),
    );
  }
}
