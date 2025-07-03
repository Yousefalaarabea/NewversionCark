import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/icon_label_model.dart';
import '../model/location_model.dart';
import 'choose_car_state.dart';

/// filter by price , number of seats, and availability

// Cubit for managing car selection
class CarCubit extends Cubit<ChooseCarState> {
  CarCubit() : super(const ChooseCarState());

  // Static list for car types with icons
  static const List<IconLabelModel> carTypes = [
    IconLabelModel(label: 'SUV', icon: Icons.directions_car_filled),
    IconLabelModel(label: 'Sedan', icon: Icons.directions_car),
    IconLabelModel(label: 'Hatchback', icon: Icons.directions_car),
    IconLabelModel(label: 'Truck', icon: Icons.local_shipping),
    IconLabelModel(label: 'Van', icon: Icons.airport_shuttle),
    IconLabelModel(label: 'Coupe', icon: Icons.time_to_leave),
    IconLabelModel(label: 'Convertible', icon: Icons.car_rental),
    IconLabelModel(label: 'Other', icon: Icons.directions_car_outlined),
  ];

  // Static list for car categories with icons
  static const List<IconLabelModel> carCategories = [
    IconLabelModel(label: 'Economy', icon: Icons.attach_money),
    IconLabelModel(label: 'Luxury', icon: Icons.star),
    IconLabelModel(label: 'Sports', icon: Icons.speed),
    IconLabelModel(label: 'Off-road', icon: Icons.terrain),
    IconLabelModel(label: 'Electric', icon: Icons.electric_car),
  ];

  // Static list for transmissions with icons
  static const List<IconLabelModel> transmissions = [
    IconLabelModel(label: 'Manual', icon: Icons.settings),
    IconLabelModel(label: 'Automatic', icon: Icons.sync),
  ];

  // Static list for driver options
  static const List<IconLabelModel> driverOptions = [
    IconLabelModel(label: 'With Driver', icon: Icons.person),
    IconLabelModel(label: 'Without Driver', icon: Icons.person_off),
  ];

  // Static list for fuel types with icons
  static const List<IconLabelModel> fuelTypes = [
    IconLabelModel(label: 'Petrol', icon: Icons.local_gas_station),
    IconLabelModel(label: 'Diesel', icon: Icons.local_gas_station_outlined),
    IconLabelModel(label: 'Electric', icon: Icons.electric_car),
    IconLabelModel(label: 'Hybrid', icon: Icons.battery_charging_full),
  ];

  /// Methods to update the state with new filter values

  // Setters for updating the state
  void setCarType(String type) => emit(
        state.copyWith(carType: type),
      );

  void setCategory(String cat) => emit(
        state.copyWith(category: cat),
      );

  void setTransmission(String trans) => emit(
        state.copyWith(transmission: trans),
      );

  void setFuel(String fuel) => emit(
        state.copyWith(fuel: fuel),
      );

  void toggleWithDriver(bool value) => emit(
        state.copyWith(withDriver: value),
      );

  void toggleWithoutDriver(bool value) => emit(
        state.copyWith(withoutDriver: value),
      );

  void setDailyPrice(double price) => emit(
        state.copyWith(dailyPrice: price),
      );

  void setMonthlyPrice(double price) => emit(
        state.copyWith(monthlyPrice: price),
      );

  void setYearlyPrice(double price) => emit(
        state.copyWith(yearlyPrice: price),
      );

  void setWithDriver(bool value) {
    emit(
      state.copyWith(withDriver: value),
    );
  }

  void resetFilters() {
    emit(
      ChooseCarState.initial(),
    );
  }

  void setPickupStation(LocationModel value) =>
      emit(state.copyWith(pickupStation: value));

  void setReturnStation(LocationModel station) {
    emit(state.copyWith(returnStation: station));
  }

  void setPickupText(String value) =>
      emit(state.copyWith(
        pickupStation: LocationModel(name: value, address: value),
      ));

  void setDropoffText(String value) =>
      emit(state.copyWith(
        returnStation: LocationModel(name: value, address: value),
      ));

  void addStop(LocationModel stop) {
    final List<LocationModel> updatedStops = List.from(state.stops)..add(stop);
    emit(state.copyWith(stops: updatedStops));
  }

  void removeStop(int index) {
    final List<LocationModel> updatedStops = List.from(state.stops)
      ..removeAt(index);
    emit(state.copyWith(stops: updatedStops));
  }

  void updateStop(int index, LocationModel stop) {
    final List<LocationModel> updatedStops = List.from(state.stops);
    updatedStops[index] = stop;
    emit(state.copyWith(stops: updatedStops));
  }

  void setPickupDate(DateTime date) {
    emit(state.copyWith(pickupDate: date));
  }


  void setDateRange(DateTimeRange range) =>
      emit(state.copyWith(dateRange: range));

  void setSelectedPaymentMethod(String method) =>
      emit(state.copyWith(selectedPaymentMethod: method));

  void enableValidation() =>
      emit(state.copyWith(showValidation: true));

  void setFilters({
    String? carType,
    String? category,
    String? transmission,
    String? fuel,
    bool? withDriver,
    bool? withoutDriver,
  }) {
    emit(state.copyWith(
      carType: carType ?? state.carType,
      category: category ?? state.category,
      transmission: transmission ?? state.transmission,
      fuel: fuel ?? state.fuel,
      withDriver: withDriver ?? state.withDriver,
      withoutDriver: withoutDriver ?? state.withoutDriver,
    ));
  }


}

/// Cubit for managing filter options
// class FilterCubit extends Cubit<FilterState> {
//   FilterCubit() : super(FilterState.initial());
//
//   void updateSelectedBrands(List<String> brands) {
//     emit(state.copyWith(selectedBrands: brands));
//   }
//
//   void updateSelectedPriceRange(RangeValues range) {
//     emit(state.copyWith(selectedPriceRange: range));
//   }
//
//   void updateSelectedModels(List<String> models) {
//     emit(state.copyWith(selectedModels: models));
//   }
//
//   void updateSelectedCarTypes(List<String> types) {
//     emit(state.copyWith(selectedCarTypes: types));
//   }
//
//   void updateSelectedAvailability(String status) {
//     emit(state.copyWith(selectedAvailability: status));
//   }
//
//   void updateSelectedCarCategories(List<String> categories){
//     emit(state.copyWith(selectedCarCategories: categories));
//   }
//
//   void updateSelectedDriverOptions (List<String> options) {
//     emit(state.copyWith(selectedDriverOptions: options));
//   }
//
//   void updateSelectedFuelTypes(List<String> fuels) {
//     emit(state.copyWith(selectedFuelTypes: fuels));
//   }
//
//   void updateSelectedTransmissionTypes(List<String> types) {
//     emit(state.copyWith(selectedTransmissionTypes: types));
//   }
//
//   void updateSelectedSeats(List<int> seats) {
//     emit(state.copyWith(selectedSeats: seats));
//   }
//
//   void updateSelectedDriverOption(String option) {
//     emit(state.copyWith(selectedDriverOption: option));
//   }
// }
