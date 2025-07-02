import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/trip_cubit.dart';
import '../../model/trip_details_model.dart';
import 'trip_details_readonly_screen.dart';

class SavedTripsScreen extends StatelessWidget {
  const SavedTripsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<TripCubit>()..loadTrips(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Saved Trips')),
        body: BlocBuilder<TripCubit, TripState>(
          builder: (context, state) {
            if (state is TripLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TripLoaded) {
              if (state.trips.isEmpty) {
                return const Center(child: Text('No saved trips.'));
              }
              return ListView.builder(
                itemCount: state.trips.length,
                itemBuilder: (context, index) {
                  final trip = state.trips[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('${trip.car.brand} ${trip.car.model}'),
                      subtitle: Text(
                          '${trip.pickupLocation} → ${trip.dropoffLocation}\n${trip.startDate.toLocal()}'),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TripDetailsReadOnlyScreen(trip: trip),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else if (state is TripError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
