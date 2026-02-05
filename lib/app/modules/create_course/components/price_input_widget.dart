import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';

class PriceInputWidget extends StatelessWidget {
  final String initialValue;
  final void Function(String?)? onChanged;
  final TextEditingController? priceController;
  final void Function(double?)? onPriceChanged;

  const PriceInputWidget({
    required this.initialValue,
    required this.onChanged,
    this.priceController,
    this.onPriceChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PrimaryContainer(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.twentyHorizontal),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: initialValue,
              underline: const SizedBox(),
              onChanged: onChanged,
              items: <String>[
                r'$',
                'Rs',
                'Inr',
                'Yuan',
              ].map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: Colors.grey.withValues(alpha: (0.5 * 255).round().toDouble()),
          ),
          Expanded(
            flex: 8,
            child: TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Enter Price'),
              onChanged: (value) {
                if (onPriceChanged != null) {
                  final price = double.tryParse(value);
                  onPriceChanged!(price);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
