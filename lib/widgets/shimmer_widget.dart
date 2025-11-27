import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nodhapp/utils/app_constant.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppConstant.BORDER_RADIUS,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppConstant.SURFACE_COLOR,
      highlightColor: Colors.grey[850]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppConstant.SURFACE_COLOR,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}