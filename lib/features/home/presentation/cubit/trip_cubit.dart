import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/trip_details_model.dart';

part 'trip_state.dart';

class TripCubit extends Cubit<TripState> {
  TripCubit() : super(TripInitial());

  List<TripDetailsModel> _trips = [];

  List<TripDetailsModel> get trips => _trips;

  Future<void> loadTrips() async {
    emit(TripLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final tripsJson = prefs.getStringList('saved_trips') ?? [];
      _trips = tripsJson.map((e) => TripDetailsModel.fromJson(json.decode(e))).toList();
      emit(TripLoaded(_trips));
    } catch (e) {
      emit(TripError('Failed to load trips'));
    }
  }

  Future<void> saveTrip(TripDetailsModel trip) async {
    emit(TripLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      _trips.add(trip);
      final tripsJson = _trips.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList('saved_trips', tripsJson);
      emit(TripLoaded(_trips));
    } catch (e) {
      emit(TripError('Failed to save trip'));
    }
  }

  Future<void> updateTrip(int index, TripDetailsModel updatedTrip) async {
    emit(TripLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      _trips[index] = updatedTrip;
      final tripsJson = _trips.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList('saved_trips', tripsJson);
      emit(TripLoaded(_trips));
    } catch (e) {
      emit(TripError('Failed to update trip'));
    }
  }
} 