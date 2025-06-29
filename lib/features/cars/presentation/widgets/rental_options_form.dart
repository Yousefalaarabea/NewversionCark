import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/car_rental_options.dart';


class RentalOptionsForm extends StatefulWidget {
  final CarRentalOptions? initialOptions;
  final Function(CarRentalOptions) onOptionsChanged;

  const RentalOptionsForm({
    super.key,
    this.initialOptions,
    required this.onOptionsChanged,
  });

  @override
  State<RentalOptionsForm> createState() => _RentalOptionsFormState();
}

class _RentalOptionsFormState extends State<RentalOptionsForm> {
  late bool _availableWithoutDriver;
  late bool _availableWithDriver;
  final _dailyPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _availableWithoutDriver = widget.initialOptions?.availableWithoutDriver ?? false;
    _availableWithDriver = widget.initialOptions?.availableWithDriver ?? false;
    _dailyPriceController.text = widget.initialOptions?.dailyRentalPrice.toString() ?? '';
  }

  @override
  void dispose() {
    _dailyPriceController.dispose();
    super.dispose();
  }

  void _updateOptions() {
    if (_dailyPriceController.text.isNotEmpty) {
      final dailyPrice = double.parse(_dailyPriceController.text);
      final options = CarRentalOptions(
        availableWithoutDriver: _availableWithoutDriver,
        availableWithDriver: _availableWithDriver,
        dailyRentalPrice: dailyPrice,
      );
      widget.onOptionsChanged(options);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rental Options',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        
        // Driver Options
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Without Driver'),
                value: _availableWithoutDriver,
                onChanged: (value) {
                  setState(() {
                    _availableWithoutDriver = value ?? false;
                    if (_availableWithoutDriver) {
                      _availableWithDriver = false;
                    }
                  });
                  _updateOptions();
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('With Driver'),
                value: _availableWithDriver,
                onChanged: (value) {
                  setState(() {
                    _availableWithDriver = value ?? false;
                    if (_availableWithDriver) {
                      _availableWithoutDriver = false;
                    }
                  });
                  _updateOptions();
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Pricing Fields
        if (_availableWithDriver || _availableWithoutDriver) ...[
          TextFormField(
            controller: _dailyPriceController,
            decoration: InputDecoration(
              labelText: 'Daily Rental Price (EGP)',
              border: const OutlineInputBorder(),
              suffixText: 'EGP',
              helperText: 'Required',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter daily rental price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid price';
              }
              return null;
            },
            onChanged: (_) => _updateOptions(),
          ),

          SizedBox(height: 16.h),

          // Show calculated prices
          if (_dailyPriceController.text.isNotEmpty) ...[
            _buildCalculatedPrice(
              'Monthly Rental Price (EGP)',
              double.parse(_dailyPriceController.text) * 30 * 0.9,
            ),
            SizedBox(height: 8.h),
            _buildCalculatedPrice(
              'Yearly Rental Price (EGP)',
              double.parse(_dailyPriceController.text) * 30 * 0.9 * 12 * 0.9,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildCalculatedPrice(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '${value.toStringAsFixed(2)} EGP',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 