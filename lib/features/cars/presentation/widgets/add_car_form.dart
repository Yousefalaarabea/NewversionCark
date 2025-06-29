import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddCarForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController modelController;
  final TextEditingController brandController;
  final TextEditingController carTypeController;
  final TextEditingController carCategoryController;
  final TextEditingController plateNumberController;
  final TextEditingController yearController;
  final TextEditingController colorController;
  final TextEditingController seatingCapacityController;
  final TextEditingController transmissionTypeController;
  final TextEditingController fuelTypeController;
  final TextEditingController odometerController;

  const AddCarForm({
    super.key,
    required this.formKey,
    required this.modelController,
    required this.brandController,
    required this.carTypeController,
    required this.carCategoryController,
    required this.plateNumberController,
    required this.yearController,
    required this.colorController,
    required this.seatingCapacityController,
    required this.transmissionTypeController,
    required this.fuelTypeController,
    required this.odometerController,
  });

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _validateAlpha(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    // Only letters and spaces allowed
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
      return 'Please enter only letters for $fieldName';
    }
    return null;
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    final n = num.tryParse(value);
    if (n == null || n < 0) {
      return 'Please enter a valid positive number for $fieldName';
    }
    return null;
  }

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter year';
    }
    final year = int.tryParse(value);
    final currentYear = DateTime.now().year;
    if (year == null || year < 1900 || year > currentYear + 1) {
      return 'Enter a valid year between 1900 and ${currentYear + 1}';
    }
    return null;
  }

  String? _validatePlateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter plate number';
    }
    // Accepts 2+ letters followed by 1+ digits
    if (!RegExp(r'^[A-Za-z]{2,}[0-9]{1,}$').hasMatch(value.trim())) {
      return 'Plate number must be at least 2 letters followed by numbers (e.g., ABC123)';
    }
    return null;
  }

  String? _validateSeatingCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter seating capacity';
    }
    final seats = int.tryParse(value);
    if (seats == null || seats < 1 || seats > 50) {
      return 'Seating capacity must be between 1 and 50';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: brandController,
            decoration: const InputDecoration(
              labelText: 'Brand',
              hintText: 'e.g., Toyota',
              prefixIcon: Icon(Icons.branding_watermark),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => _validateAlpha(value, 'brand'),
          ),
          SizedBox(height: 0.02.sh),

          TextFormField(
            controller: modelController,
            decoration: const InputDecoration(
              labelText: 'Model',
              hintText: 'e.g., Corolla',
              prefixIcon: Icon(Icons.model_training),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => _validateAlpha(value, 'model'),
          ),
          SizedBox(height: 0.02.sh),

          TextFormField(
            controller: carTypeController,
            decoration: const InputDecoration(
              labelText: 'Car Type',
              hintText: 'e.g., Sedan, SUV',
              prefixIcon: Icon(Icons.car_rental),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => _validateAlpha(value, 'car type'),
          ),
          SizedBox(height: 0.02.sh),

          TextFormField(
            controller: carCategoryController,
            decoration: const InputDecoration(
              labelText: 'Car Category',
              hintText: 'e.g., Economy, Luxury',
              prefixIcon: Icon(Icons.category),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => _validateAlpha(value, 'car category'),
          ),
          SizedBox(height: 0.02.sh),

          TextFormField(
            controller: plateNumberController,
            decoration: const InputDecoration(
              labelText: 'Plate Number',
              hintText: 'e.g., ABC123',
              prefixIcon: Icon(Icons.pin),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: _validatePlateNumber,
          ),
          SizedBox(height: 0.02.sh),

          TextFormField(
            controller: yearController,
            decoration: const InputDecoration(
              labelText: 'Year',
              hintText: 'e.g., 2020',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.number,
            validator: _validateYear,
          ),
          SizedBox(height: 0.02.sh),

          TextFormField(
            controller: colorController,
            decoration: const InputDecoration(
              labelText: 'Color',
              hintText: 'e.g., Red',
              prefixIcon: Icon(Icons.color_lens),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => _validateAlpha(value, 'color'),
          ),
          SizedBox(height: 0.02.sh),

          TextFormField(
            controller: seatingCapacityController,
            decoration: const InputDecoration(
              labelText: 'Seating Capacity',
              hintText: 'e.g., 5',
              prefixIcon: Icon(Icons.airline_seat_recline_normal),
            ),
            keyboardType: TextInputType.number,
            validator: _validateSeatingCapacity,
          ),
          SizedBox(height: 0.02.sh),

          TextFormField(
            controller: transmissionTypeController,
            decoration: const InputDecoration(
              labelText: 'Transmission Type',
              hintText: 'e.g., Automatic, Manual',
              prefixIcon: Icon(Icons.settings),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => _validateAlpha(value, 'transmission type'),
          ),
          SizedBox(height: 0.02.sh),

          TextFormField(
            controller: fuelTypeController,
            decoration: const InputDecoration(
              labelText: 'Fuel Type',
              hintText: 'e.g., Petrol, Diesel',
              prefixIcon: Icon(Icons.local_gas_station),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => _validateAlpha(value, 'fuel type'),
          ),
          SizedBox(height: 0.02.sh),

          TextFormField(
            controller: odometerController,
            decoration: const InputDecoration(
              labelText: 'Odometer Reading',
              hintText: 'e.g., 35000',
              prefixIcon: Icon(Icons.speed),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => _validateNumber(value, 'odometer reading'),
          ),
          SizedBox(height: 0.04.sh),
        ],
      ),
    );
  }
}