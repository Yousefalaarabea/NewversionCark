// Car States
import 'package:flutter/material.dart';
import '../model/location_model.dart';
import 'package:equatable/equatable.dart';

class ChooseCarState extends Equatable {
  final String? carType;
  final String? category;
  final String? transmission;
  final String? fuel;
  final bool? withDriver;
  final bool? withoutDriver;
  final double? dailyPrice;
  final double? monthlyPrice;
  final double? yearlyPrice;

  // NEW FIELDS
  final LocationModel? pickupStation;
  final LocationModel? returnStation;
  final List<LocationModel> stops;
  final DateTime? pickupDate;
  final DateTime? returnDate;
  final DateTimeRange? dateRange;
  final String? selectedPaymentMethod;
  
  // Validation flags
  final bool showValidation;

  /// Constructors
  const ChooseCarState({
    this.carType,
    this.category,
    this.transmission,
    this.fuel,
    this.withDriver,
    this.withoutDriver,
    this.dailyPrice,
    this.monthlyPrice,
    this.yearlyPrice,
    this.pickupStation,
    this.returnStation,
    this.stops = const [],
    this.pickupDate,
    this.returnDate,
    this.dateRange,
    this.selectedPaymentMethod,
    this.showValidation = false,
  });

  // Initial state (all filters cleared)
  factory ChooseCarState.initial() {
    return const ChooseCarState();
  }

  ChooseCarState copyWith({
    String? carType,
    String? category,
    String? transmission,
    String? fuel,
    bool? withDriver,
    bool? withoutDriver,
    double? dailyPrice,
    double? monthlyPrice,
    double? yearlyPrice,
    LocationModel? pickupStation,
    LocationModel? returnStation,
    List<LocationModel>? stops,
    DateTime? pickupDate,
    DateTime? returnDate,
    DateTimeRange? dateRange,
    String? selectedPaymentMethod,
    bool? showValidation,
  }) {
    return ChooseCarState(
      // Use the existing value if the new value is null
      carType: carType ?? this.carType,
      category: category ?? this.category,
      transmission: transmission ?? this.transmission,
      fuel: fuel ?? this.fuel,
      withDriver: withDriver ?? this.withDriver,
      withoutDriver: withoutDriver ?? this.withoutDriver,
      dailyPrice: dailyPrice ?? this.dailyPrice,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      pickupStation: pickupStation ?? this.pickupStation,
      returnStation: returnStation ?? this.returnStation,
      stops: stops ?? this.stops,
      pickupDate: pickupDate ?? this.pickupDate,
      returnDate: returnDate ?? this.returnDate,
      dateRange: dateRange ?? this.dateRange,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      showValidation: showValidation ?? this.showValidation,
    );
  }

  @override
  List<Object?> get props => [
        carType,
        category,
        transmission,
        fuel,
        withDriver,
        withoutDriver,
        dailyPrice,
        monthlyPrice,
        yearlyPrice,
        pickupStation,
        returnStation,
        stops,
        pickupDate,
        returnDate,
        dateRange,
        selectedPaymentMethod,
        showValidation,
      ];
}

// Filter States
// abstract class FilterState {}
//
// class FilterInitial extends FilterState {}
//
// class FilterUpdated extends FilterState {}
//
// class FilterError extends FilterState {
//   final String message;
//   FilterError(this.message);
// }
//
// class FilterState {
//   final List<String> selectedBrands;
//   final RangeValues selectedPriceRange;
//   final List<String> selectedModels;
//   final List<String> selectedCarTypes;
//   final String selectedAvailability;
//   final List<String> selectedCarCategories;
//   final List<String> selectedDriverOptions;
//   final List<String> selectedFuelTypes;
//   final List<String> selectedTransmissionTypes;
//   final List<int> selectedSeats;
//   final String selectedDriverOption;
//
//   FilterState({
//     required this.selectedBrands,
//     required this.selectedPriceRange,
//     required this.selectedModels,
//     required this.selectedCarTypes,
//     required this.selectedAvailability,
//     required  this.selectedCarCategories,
//     required  this.selectedDriverOptions,
//     required this.selectedFuelTypes,
//     required this.selectedTransmissionTypes,
//     required this.selectedSeats,
//     required this.selectedDriverOption,
//   });
//
//   factory FilterState.initial() {
//     return FilterState(
//       selectedBrands: [],
//       selectedPriceRange: const RangeValues(0, 1000),
//       selectedModels: [],
//       selectedCarTypes: [],
//       selectedAvailability: "Available",
//       selectedCarCategories: [],
//       selectedDriverOptions: [],
//       selectedFuelTypes: [],
//       selectedTransmissionTypes: [],
//       selectedSeats: [],
//       selectedDriverOption: "withoutDriver",
//     );
//   }
//
//   FilterState copyWith({
//     List<String>? selectedBrands,
//     RangeValues? selectedPriceRange,
//     List<String>? selectedModels,
//     List<String>? selectedCarTypes,
//     String? selectedAvailability,
//     List<String>? selectedCarCategories,
//     List<String>? selectedDriverOptions,
//     List<String>? selectedFuelTypes,
//     List<String>? selectedTransmissionTypes,
//     List<int>? selectedSeats,
//     String? selectedDriverOption,
//   }) {
//     return FilterState(
//       selectedBrands: selectedBrands ?? this.selectedBrands,
//       selectedPriceRange: selectedPriceRange ?? this.selectedPriceRange,
//       selectedModels: selectedModels ?? this.selectedModels,
//       selectedCarTypes: selectedCarTypes ?? this.selectedCarTypes,
//       selectedAvailability: selectedAvailability ?? this.selectedAvailability,
//       selectedCarCategories : selectedCarCategories ?? this.selectedCarCategories,
//       selectedDriverOptions : selectedDriverOptions ?? this.selectedDriverOptions,
//       selectedFuelTypes: selectedFuelTypes ?? this.selectedFuelTypes,
//       selectedTransmissionTypes: selectedTransmissionTypes ?? this.selectedTransmissionTypes,
//       selectedSeats: selectedSeats ?? this.selectedSeats,
//       selectedDriverOption: selectedDriverOption ?? this.selectedDriverOption,
//     );
//   }
// }
