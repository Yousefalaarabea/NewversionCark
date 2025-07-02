// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class AddCarForm extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController modelController;
//   final TextEditingController brandController;
//   final TextEditingController carTypeController;
//   final TextEditingController carCategoryController;
//   final TextEditingController plateNumberController;
//   final TextEditingController yearController;
//   final TextEditingController colorController;
//   final TextEditingController seatingCapacityController;
//   final TextEditingController transmissionTypeController;
//   final TextEditingController fuelTypeController;
//   final TextEditingController odometerController;
//
//   const AddCarForm({
//     super.key,
//     required this.formKey,
//     required this.modelController,
//     required this.brandController,
//     required this.carTypeController,
//     required this.carCategoryController,
//     required this.plateNumberController,
//     required this.yearController,
//     required this.colorController,
//     required this.seatingCapacityController,
//     required this.transmissionTypeController,
//     required this.fuelTypeController,
//     required this.odometerController,
//   });
//
//   String? _validateNotEmpty(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter $fieldName';
//     }
//     return null;
//   }
//
//   String? _validateAlpha(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter $fieldName';
//     }
//     // Only letters and spaces allowed
//     if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
//       return 'Please enter only letters for $fieldName';
//     }
//     return null;
//   }
//
//   String? _validateNumber(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter $fieldName';
//     }
//     final n = num.tryParse(value);
//     if (n == null || n < 0) {
//       return 'Please enter a valid positive number for $fieldName';
//     }
//     return null;
//   }
//
//   String? _validateYear(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter year';
//     }
//     final year = int.tryParse(value);
//     final currentYear = DateTime.now().year;
//     if (year == null || year < 1900 || year > currentYear + 1) {
//       return 'Enter a valid year between 1900 and ${currentYear + 1}';
//     }
//     return null;
//   }
//
//   String? _validatePlateNumber(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter plate number';
//     }
//     // Accepts 2+ letters followed by 1+ digits
//     if (!RegExp(r'^[A-Za-z]{2,}[0-9]{1,}$').hasMatch(value.trim())) {
//       return 'Plate number must be at least 2 letters followed by numbers (e.g., ABC123)';
//     }
//     return null;
//   }
//
//   String? _validateSeatingCapacity(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter seating capacity';
//     }
//     final seats = int.tryParse(value);
//     if (seats == null || seats < 1 || seats > 50) {
//       return 'Seating capacity must be between 1 and 50';
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: formKey,
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           TextFormField(
//             controller: brandController,
//             decoration: const InputDecoration(
//               labelText: 'Brand',
//               hintText: 'e.g., Toyota',
//               prefixIcon: Icon(Icons.branding_watermark),
//             ),
//             textCapitalization: TextCapitalization.words,
//             validator: (value) => _validateAlpha(value, 'brand'),
//           ),
//           SizedBox(height: 0.02.sh),
//
//           TextFormField(
//             controller: modelController,
//             decoration: const InputDecoration(
//               labelText: 'Model',
//               hintText: 'e.g., Corolla',
//               prefixIcon: Icon(Icons.model_training),
//             ),
//             textCapitalization: TextCapitalization.words,
//             validator: (value) => _validateAlpha(value, 'model'),
//           ),
//           SizedBox(height: 0.02.sh),
//
//           TextFormField(
//             controller: carTypeController,
//             decoration: const InputDecoration(
//               labelText: 'Car Type',
//               hintText: 'e.g., Sedan, SUV',
//               prefixIcon: Icon(Icons.car_rental),
//             ),
//             textCapitalization: TextCapitalization.words,
//             validator: (value) => _validateAlpha(value, 'car type'),
//           ),
//           SizedBox(height: 0.02.sh),
//
//           TextFormField(
//             controller: carCategoryController,
//             decoration: const InputDecoration(
//               labelText: 'Car Category',
//               hintText: 'e.g., Economy, Luxury',
//               prefixIcon: Icon(Icons.category),
//             ),
//             textCapitalization: TextCapitalization.words,
//             validator: (value) => _validateAlpha(value, 'car category'),
//           ),
//           SizedBox(height: 0.02.sh),
//
//           TextFormField(
//             controller: plateNumberController,
//             decoration: const InputDecoration(
//               labelText: 'Plate Number',
//               hintText: 'e.g., ABC123',
//               prefixIcon: Icon(Icons.pin),
//             ),
//             textCapitalization: TextCapitalization.characters,
//             validator: _validatePlateNumber,
//           ),
//           SizedBox(height: 0.02.sh),
//
//           TextFormField(
//             controller: yearController,
//             decoration: const InputDecoration(
//               labelText: 'Year',
//               hintText: 'e.g., 2020',
//               prefixIcon: Icon(Icons.calendar_today),
//             ),
//             keyboardType: TextInputType.number,
//             validator: _validateYear,
//           ),
//           SizedBox(height: 0.02.sh),
//
//           TextFormField(
//             controller: colorController,
//             decoration: const InputDecoration(
//               labelText: 'Color',
//               hintText: 'e.g., Red',
//               prefixIcon: Icon(Icons.color_lens),
//             ),
//             textCapitalization: TextCapitalization.words,
//             validator: (value) => _validateAlpha(value, 'color'),
//           ),
//           SizedBox(height: 0.02.sh),
//
//           TextFormField(
//             controller: seatingCapacityController,
//             decoration: const InputDecoration(
//               labelText: 'Seating Capacity',
//               hintText: 'e.g., 5',
//               prefixIcon: Icon(Icons.airline_seat_recline_normal),
//             ),
//             keyboardType: TextInputType.number,
//             validator: _validateSeatingCapacity,
//           ),
//           SizedBox(height: 0.02.sh),
//
//           TextFormField(
//             controller: transmissionTypeController,
//             decoration: const InputDecoration(
//               labelText: 'Transmission Type',
//               hintText: 'e.g., Automatic, Manual',
//               prefixIcon: Icon(Icons.settings),
//             ),
//             textCapitalization: TextCapitalization.words,
//             validator: (value) => _validateAlpha(value, 'transmission type'),
//           ),
//           SizedBox(height: 0.02.sh),
//
//           TextFormField(
//             controller: fuelTypeController,
//             decoration: const InputDecoration(
//               labelText: 'Fuel Type',
//               hintText: 'e.g., Petrol, Diesel',
//               prefixIcon: Icon(Icons.local_gas_station),
//             ),
//             textCapitalization: TextCapitalization.words,
//             validator: (value) => _validateAlpha(value, 'fuel type'),
//           ),
//           SizedBox(height: 0.02.sh),
//
//           TextFormField(
//             controller: odometerController,
//             decoration: const InputDecoration(
//               labelText: 'Odometer Reading',
//               hintText: 'e.g., 35000',
//               prefixIcon: Icon(Icons.speed),
//             ),
//             keyboardType: TextInputType.number,
//             validator: (value) => _validateNumber(value, 'odometer reading'),
//           ),
//           SizedBox(height: 0.04.sh),
//         ],
//       ),
//     );
//   }
// }
// v2
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class AddCarForm extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController modelController;
//   final TextEditingController brandController;
//   final TextEditingController carTypeController;
//   final TextEditingController carCategoryController;
//   final TextEditingController plateNumberController;
//   final TextEditingController yearController;
//   final TextEditingController colorController;
//   final TextEditingController seatingCapacityController;
//   final TextEditingController transmissionTypeController;
//   final TextEditingController fuelTypeController;
//   final TextEditingController odometerController;
//   final TextEditingController currentStatusController;
//
//   const AddCarForm({
//     super.key,
//     required this.formKey,
//     required this.modelController,
//     required this.brandController,
//     required this.carTypeController,
//     required this.carCategoryController,
//     required this.plateNumberController,
//     required this.yearController,
//     required this.colorController,
//     required this.seatingCapacityController,
//     required this.transmissionTypeController,
//     required this.fuelTypeController,
//     required this.odometerController,
//     required this.currentStatusController,
//   });
//
//   static const List<String> carTypeChoices = [
//     'SUV',
//     'Sedan',
//     'Hatchback',
//     'Truck',
//     'Van',
//     'Coupe',
//     'Convertible',
//     'Other',
//   ];
//
//   static const List<String> carCategoryChoices = [
//     'Economy',
//     'Luxury',
//     'Sports',
//     'Off-road',
//     'Electric',
//     'Other',
//   ];
//
//   static const List<String> transmissionChoices = [
//     'Manual',
//     'Automatic',
//   ];
//
//   static const List<String> fuelChoices = [
//     'Petrol',
//     'Diesel',
//     'Electric',
//     'Hybrid',
//     'Other',
//   ];
//
//   static const List<String> statusChoices = [
//     'Available',
//     'Booked',
//     'InUse',
//     'UnderMaintenance',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: formKey,
//       child: Column(
//         children: [
//           TextFormField(
//             controller: brandController,
//             decoration: InputDecoration(
//               labelText: 'Brand',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter the car brand';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16.h),
//           TextFormField(
//             controller: modelController,
//             decoration: InputDecoration(
//               labelText: 'Model',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter the car model';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16.h),
//           DropdownButtonFormField<String>(
//             value: carTypeController.text.isNotEmpty ? carTypeController.text : null,
//             decoration: InputDecoration(
//               labelText: 'Car Type',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             items: carTypeChoices.map((type) {
//               return DropdownMenuItem<String>(
//                 value: type,
//                 child: Text(type),
//               );
//             }).toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 carTypeController.text = value;
//               }
//             },
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please select a car type';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16.h),
//           DropdownButtonFormField<String>(
//             value: carCategoryController.text.isNotEmpty ? carCategoryController.text : null,
//             decoration: InputDecoration(
//               labelText: 'Car Category',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             items: carCategoryChoices.map((category) {
//               return DropdownMenuItem<String>(
//                 value: category,
//                 child: Text(category),
//               );
//             }).toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 carCategoryController.text = value;
//               }
//             },
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please select a car category';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16.h),
//           TextFormField(
//             controller: plateNumberController,
//             decoration: InputDecoration(
//               labelText: 'Plate Number',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter the plate number';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16.h),
//           TextFormField(
//             controller: yearController,
//             decoration: InputDecoration(
//               labelText: 'Year',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter the car year';
//               }
//               if (int.tryParse(value) == null || int.parse(value) < 1900 || int.parse(value) > DateTime.now().year) {
//                 return 'Please enter a valid year';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16.h),
//           TextFormField(
//             controller: colorController,
//             decoration: InputDecoration(
//               labelText: 'Color',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter the car color';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16.h),
//           TextFormField(
//             controller: seatingCapacityController,
//             decoration: InputDecoration(
//               labelText: 'Seating Capacity',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter the seating capacity';
//               }
//               if (int.tryParse(value) == null || int.parse(value) <= 0) {
//                 return 'Please enter a valid seating capacity';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16.h),
//           DropdownButtonFormField<String>(
//             value: transmissionTypeController.text.isNotEmpty ? transmissionTypeController.text : null,
//             decoration: InputDecoration(
//               labelText: 'Transmission Type',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             items: transmissionChoices.map((transmission) {
//               return DropdownMenuItem<String>(
//                 value: transmission,
//                 child: Text(transmission),
//               );
//             }).toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 transmissionTypeController.text = value;
//               }
//             },
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please select a transmission type';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16.h),
//           DropdownButtonFormField<String>(
//             value: fuelTypeController.text.isNotEmpty ? fuelTypeController.text : null,
//             decoration: InputDecoration(
//               labelText: 'Fuel Type',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             items: fuelChoices.map((fuel) {
//               return DropdownMenuItem<String>(
//                 value: fuel,
//                 child: Text(fuel),
//               );
//             }).toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 fuelTypeController.text = value;
//               }
//             },
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please select a fuel type';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16.h),
//           DropdownButtonFormField<String>(
//             value: statusChoices.contains(currentStatusController.text) ? currentStatusController.text : null,
//             decoration: InputDecoration(
//               labelText: 'Current Status',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             items: statusChoices.map((status) {
//               return DropdownMenuItem<String>(
//                 value: status,
//                 child: Text(status),
//               );
//             }).toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 currentStatusController.text = value;
//               }
//             },
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please select a current status';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16.h),
//           TextFormField(
//             controller: odometerController,
//             decoration: InputDecoration(
//               labelText: 'Odometer Reading (km)',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//             ),
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter the odometer reading';
//               }
//               if (int.tryParse(value) == null || int.parse(value) < 0) {
//                 return 'Please enter a valid odometer reading';
//               }
//               return null;
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/themes/app_colors.dart';

class AddCarForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController modelController;
  final TextEditingController brandController;
  final TextEditingController carTypeController;
  final TextEditingController carCategoryController;
  final TextEditingController plateNumberController;
  final GlobalKey<FormFieldState> plateNumberFieldKey;
  final String? plateNumberError;
  final TextEditingController yearController;
  final TextEditingController colorController;
  final TextEditingController seatingCapacityController;
  final TextEditingController transmissionTypeController;
  final TextEditingController fuelTypeController;
  final TextEditingController odometerController;
  final TextEditingController currentStatusController;

  const AddCarForm({
    super.key,
    required this.formKey,
    required this.modelController,
    required this.brandController,
    required this.carTypeController,
    required this.carCategoryController,
    required this.plateNumberController,
    required this.plateNumberFieldKey,
    this.plateNumberError,
    required this.yearController,
    required this.colorController,
    required this.seatingCapacityController,
    required this.transmissionTypeController,
    required this.fuelTypeController,
    required this.odometerController,
    required this.currentStatusController,
  });

  @override
  _AddCarFormState createState() => _AddCarFormState();
}

class _AddCarFormState extends State<AddCarForm> {
  static const Map<String, List<String>> carBrandModels = {
    'Toyota': ['Camry', 'Corolla', 'RAV4', 'Highlander', 'Prius'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot', 'Fit'],
    'Ford': ['Mustang', 'F-150', 'Explorer', 'Focus', 'Escape'],
    'BMW': ['3 Series', '5 Series', 'X5', 'M3', 'i4'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'A-Class'],
    'Audi': ['A4', 'Q5', 'A6', 'Q7', 'e-tron'],
    'Volkswagen': ['Golf', 'Passat', 'Tiguan', 'Jetta', 'Arteon'],
    'Hyundai': ['Tucson', 'Elantra', 'Santa Fe', 'Sonata', 'Kona'],
    'Kia': ['Sportage', 'Sorento', 'Optima', 'Soul', 'Telluride'],
    'Chevrolet': ['Malibu', 'Equinox', 'Silverado', 'Camaro', 'Blazer'],
    'Nissan': ['Altima', 'Rogue', 'Sentra', 'Pathfinder', 'Leaf'],
    'Tesla': ['Model 3', 'Model S', 'Model X', 'Model Y', 'Cybertruck'],
    'Subaru': ['Outback', 'Forester', 'Impreza', 'Crosstrek', 'WRX'],
    'Mazda': ['CX-5', 'Mazda3', 'Mazda6', 'CX-9', 'MX-5 Miata'],
    'Lexus': ['RX', 'ES', 'NX', 'IS', 'GX'],
    'Porsche': ['911', 'Cayenne', 'Macan', 'Panamera', 'Taycan'],
    'Jeep': ['Wrangler', 'Grand Cherokee', 'Cherokee', 'Compass', 'Gladiator'],
    'Volvo': ['XC90', 'XC60', 'S60', 'V90', 'XC40'],
    'Jaguar': ['F-Pace', 'XE', 'XF', 'F-Type', 'I-Pace'],
    'Land Rover': ['Range Rover', 'Discovery', 'Defender', 'Evoque', 'Velar'],
  };

  static const List<String> carTypeChoices = [
    'SUV',
    'Sedan',
    'Hatchback',
    'Truck',
    'Van',
    'Coupe',
    'Convertible',
    'Other',
  ];

  static const List<String> carCategoryChoices = [
    'Economy',
    'Luxury',
    'Sports',
    'Off-road',
    'Electric',
    'Other',
  ];

  static const List<String> transmissionChoices = [
    'Manual',
    'Automatic',
  ];

  static const List<String> fuelChoices = [
    'Petrol',
    'Diesel',
    'Electric',
    'Hybrid',
    'Other',
  ];

  static const List<String> statusChoices = [
    'Available',
    'Booked',
    'InUse',
    'UnderMaintenance',
  ];

  List<String> _availableModels = [];

  @override
  void initState() {
    super.initState();
    // Initialize available models based on initial brand
    if (widget.brandController.text.isNotEmpty && carBrandModels.containsKey(widget.brandController.text)) {
      _availableModels = carBrandModels[widget.brandController.text]!;
    }
    widget.brandController.addListener(_updateModels);
  }

  void _updateModels() {
    setState(() {
      final selectedBrand = widget.brandController.text;
      _availableModels = carBrandModels[selectedBrand] ?? [];
      if (!_availableModels.contains(widget.modelController.text)) {
        widget.modelController.clear();
      }
    });
  }

  @override
  void dispose() {
    widget.brandController.removeListener(_updateModels);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: widget.brandController.text.isNotEmpty && carBrandModels.containsKey(widget.brandController.text)
                ? widget.brandController.text
                : null,
            decoration: InputDecoration(
              labelText: 'Brand',
              prefixIcon: Icon(Icons.directions_car, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
            items: carBrandModels.keys.map((brand) {
              return DropdownMenuItem<String>(
                value: brand,
                child: Text(brand, style: TextStyle(fontSize: 16.sp)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.brandController.text = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a car brand';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: widget.modelController.text.isNotEmpty && _availableModels.contains(widget.modelController.text)
                ? widget.modelController.text
                : null,
            decoration: InputDecoration(
              labelText: 'Model',
              prefixIcon: Icon(Icons.model_training, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
            items: _availableModels.map((model) {
              return DropdownMenuItem<String>(
                value: model,
                child: Text(model, style: TextStyle(fontSize: 16.sp)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.modelController.text = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a car model';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: widget.carTypeController.text.isNotEmpty ? widget.carTypeController.text : null,
            decoration: InputDecoration(
              labelText: 'Car Type',
              prefixIcon: Icon(Icons.car_rental, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
            items: carTypeChoices.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type, style: TextStyle(fontSize: 16.sp)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.carTypeController.text = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a car type';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: widget.carCategoryController.text.isNotEmpty ? widget.carCategoryController.text : null,
            decoration: InputDecoration(
              labelText: 'Car Category',
              prefixIcon: Icon(Icons.category, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
            items: carCategoryChoices.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category, style: TextStyle(fontSize: 16.sp)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.carCategoryController.text = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a car category';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            key: widget.plateNumberFieldKey,
            controller: widget.plateNumberController,
            decoration: InputDecoration(
              labelText: 'Plate Number',
              prefixIcon: Icon(Icons.confirmation_number, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
              errorStyle: TextStyle(fontSize: 12.sp, color: Colors.redAccent),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the plate number';
              }
              if (widget.plateNumberError != null) {
                return widget.plateNumberError;
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: widget.yearController,
            decoration: InputDecoration(
              labelText: 'Year',
              prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the car year';
              }
              if (int.tryParse(value) == null || int.parse(value) < 1900 || int.parse(value) > DateTime.now().year) {
                return 'Please enter a valid year';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: widget.colorController,
            decoration: InputDecoration(
              labelText: 'Color',
              prefixIcon: Icon(Icons.color_lens, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the car color';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: widget.seatingCapacityController,
            decoration: InputDecoration(
              labelText: 'Seating Capacity',
              prefixIcon: Icon(Icons.event_seat, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the seating capacity';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Please enter a valid seating capacity';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: widget.transmissionTypeController.text.isNotEmpty ? widget.transmissionTypeController.text : null,
            decoration: InputDecoration(
              labelText: 'Transmission Type',
              prefixIcon: Icon(Icons.settings, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
            items: transmissionChoices.map((transmission) {
              return DropdownMenuItem<String>(
                value: transmission,
                child: Text(transmission, style: TextStyle(fontSize: 16.sp)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.transmissionTypeController.text = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a transmission type';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: widget.fuelTypeController.text.isNotEmpty ? widget.fuelTypeController.text : null,
            decoration: InputDecoration(
              labelText: 'Fuel Type',
              prefixIcon: Icon(Icons.local_gas_station, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
            items: fuelChoices.map((fuel) {
              return DropdownMenuItem<String>(
                value: fuel,
                child: Text(fuel, style: TextStyle(fontSize: 16.sp)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.fuelTypeController.text = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a fuel type';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: statusChoices.contains(widget.currentStatusController.text) ? widget.currentStatusController.text : null,
            decoration: InputDecoration(
              labelText: 'Current Status',
              prefixIcon: Icon(Icons.info, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
            items: statusChoices.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status, style: TextStyle(fontSize: 16.sp)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.currentStatusController.text = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a current status';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: widget.odometerController,
            decoration: InputDecoration(
              labelText: 'Odometer Reading (km)',
              prefixIcon: Icon(Icons.speed, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2.w),
              ),
              labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the odometer reading';
              }
              if (int.tryParse(value) == null || int.parse(value) < 0) {
                return 'Please enter a valid odometer reading';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}