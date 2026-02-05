import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/create_course/components/price_input_widget.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';

class PublishCourseView extends StatefulWidget {
  final void Function(double?)? onPriceChanged;
  final double? price;
  final Uint8List? courseImage;

  const PublishCourseView({
    super.key,
    this.onPriceChanged,
    this.price,
    this.courseImage,
  });

  @override
  State<PublishCourseView> createState() => _PublishCourseViewState();
}

class _PublishCourseViewState extends State<PublishCourseView> {
  String selectedCurrency = r'$';
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.price != null) {
      _priceController.text = widget.price!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.twentyHorizontal),
      child: Column(
        children: [
          SizedBox(
            width: double.maxFinite,
            child: PrimaryContainer(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course Preview',
                    style: AppTypography.kBold18,
                  ),
                  SizedBox(height: 12.h),
                  if (widget.courseImage != null)
                    Container(
                      height: 120.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        image: DecorationImage(
                          image: MemoryImage(widget.courseImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Your course will appear here once published',
                      style: AppTypography.kLight14,
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 23.h),
          PriceInputWidget(
            initialValue: selectedCurrency,
            priceController: _priceController,
            onChanged: (value) {
              setState(() {
                selectedCurrency = value ?? r'$';
              });
            },
            onPriceChanged: (price) {
              if (widget.onPriceChanged != null) {
                widget.onPriceChanged!(price);
              }
            },
          ),
          SizedBox(height: 70.h),
        ],
      ),
    );
  }
}
