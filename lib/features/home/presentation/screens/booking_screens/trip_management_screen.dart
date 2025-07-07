import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/car_model.dart';
import '../../model/location_model.dart';
import '../../../../../config/routes/screens_name.dart';

class TripManagementScreen extends StatefulWidget {
  final CarModel car;
  final double totalPrice;
  final List<LocationModel> stops;
  final String tripId;
  final String renterId;
  final String ownerId;
  final String paymentMethod;

  const TripManagementScreen({
    super.key,
    required this.car,
    required this.totalPrice,
    required this.stops,
    required this.tripId,
    required this.renterId,
    required this.ownerId,
    required this.paymentMethod,
  });

  @override
  State<TripManagementScreen> createState() => _TripManagementScreenState();
}

class _TripManagementScreenState extends State<TripManagementScreen>
    with TickerProviderStateMixin {
  bool isTripStarted = false;
  int currentStopIndex = 0;
  late AnimationController _timerController;
  late AnimationController _pulseController;
  Duration tripDuration = Duration.zero;
  List<StopStatus> stopStatuses = [];
  bool showMap = false;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    stopStatuses = List.generate(
      widget.stops.length,
          (index) => StopStatus(
        location: widget.stops[index],
        isCompleted: false,
        isCurrent: index == 0,
        duration: Duration.zero,
      ),
    );

    _startTimer();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timerController.repeat();
    _timerController.addListener(() {
      setState(() {
        tripDuration += const Duration(seconds: 1);
        if (stopStatuses.isNotEmpty && currentStopIndex < stopStatuses.length) {
          stopStatuses[currentStopIndex].duration += const Duration(seconds: 1);
        }
      });
    });
  }

  void _startTrip() {
    setState(() {
      isTripStarted = true;
      showMap = true;
    });
    _pulseController.repeat(reverse: true);
  }

  void _stopOrder() {
    setState(() {
      isTripStarted = false;
      showMap = false;
    });
    _pulseController.stop();
  }

  void _confirmArrival() {
    if (currentStopIndex < stopStatuses.length) {
      setState(() {
        stopStatuses[currentStopIndex].isCompleted = true;
        stopStatuses[currentStopIndex].isCurrent = false;

        if (currentStopIndex + 1 < stopStatuses.length) {
          currentStopIndex++;
          stopStatuses[currentStopIndex].isCurrent = true;
        } else {
          _showPaymentConfirmation();
        }
      });
    }
  }

  void _showPaymentConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Trip Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Trip Duration: ${_formatDuration(tripDuration)}'),
            const SizedBox(height: 16),
            Text('Total Price: ${widget.totalPrice.toStringAsFixed(2)} EGP'),
            const SizedBox(height: 16),
            const Text('Proceed to payment?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToPayment();
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    Navigator.of(context).pop();
    Navigator.pushNamed(
      context,
      '/payment_screen',
      arguments: {
        'totalPrice': widget.totalPrice,
        'car': widget.car,
      },
    );
  }

  String _formatDuration(Duration duration) {
    return '${(duration.inHours).toString().padLeft(2, '0')}:${(duration.inMinutes.remainder(60)).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (isTripStarted)
            IconButton(
              onPressed: _stopOrder,
              icon: const Icon(Icons.stop),
              tooltip: 'Stop Order',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildTripStatusCard(),
          if (!isTripStarted) _buildStartTripButton(),
          if (showMap) _buildMapPlaceholder(),
          _buildStopsList(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text('Get Current GPS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _finishTrip,
                  icon: const Icon(Icons.flag),
                  label: const Text('Finish Trip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripStatusCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trip Status', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isTripStarted ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isTripStarted ? 'Active' : 'Ready',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Duration', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                  Text(
                    _formatDuration(tripDuration),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Stops', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                  Text(
                    '${currentStopIndex + 1}/${widget.stops.length}',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartTripButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow),
            SizedBox(width: 8.w),
            Text('Start Trip', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      margin: EdgeInsets.all(16.w),
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 48.sp, color: Colors.grey[400]),
                SizedBox(height: 8.h),
                Text('Map View', style: TextStyle(fontSize: 16.sp, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                SizedBox(height: 4.h),
                Text('Navigating to destination...', style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
              ],
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: KeyedSubtree(
              key: UniqueKey(),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8 - _pulseController.value * 0.4),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsList() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: ListView.builder(
          itemCount: stopStatuses.length,
          itemBuilder: (context, index) {
            final stop = stopStatuses[index];
            return KeyedSubtree(
              key: ValueKey(index),
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: stop.isCurrent ? Colors.blue : stop.isCompleted ? Colors.green : Colors.grey[300]!,
                    width: stop.isCurrent ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: stop.isCompleted
                            ? Colors.green
                            : stop.isCurrent
                            ? Colors.blue
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        stop.isCompleted
                            ? Icons.check
                            : stop.isCurrent
                            ? Icons.location_on
                            : Icons.location_off,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Stop ${index + 1}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: stop.isCurrent ? Colors.blue : stop.isCompleted ? Colors.green : Colors.black)),
                          SizedBox(height: 4.h),
                          Text(stop.location.name, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                          if (stop.isCurrent && isTripStarted) ...[
                            SizedBox(height: 8.h),
                            Text('Timer: ${_formatDuration(stop.duration)}', style: TextStyle(fontSize: 12.sp, color: Colors.blue, fontWeight: FontWeight.w500)),
                          ],
                        ],
                      ),
                    ),
                    if (stop.isCurrent && isTripStarted)
                      ElevatedButton(
                        onPressed: _confirmArrival,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: Text('Confirm Arrival', style: TextStyle(fontSize: 12.sp)),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم جلب الموقع الحالي (اختبار).')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب الموقع: $e')),
      );
    }
  }

  void _finishTrip() {
    Navigator.pushNamed(
      context,
      ScreensName.renterDropOffScreen,
      arguments: {
        'tripId': widget.tripId,
        'carId': widget.car.id.toString(),
        'renterId': widget.renterId,
        'ownerId': widget.ownerId,
        'paymentMethod': widget.paymentMethod,
      },
    );
  }
}

class StopStatus {
  final LocationModel location;
  bool isCompleted;
  bool isCurrent;
  Duration duration;

  StopStatus({
    required this.location,
    required this.isCompleted,
    required this.isCurrent,
    required this.duration,
  });
}