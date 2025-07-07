// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
// // import 'package:latlong2/latlong.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// //
// // import '../../../../config/themes/app_colors.dart';
// //
// // class LiveLocationMapScreen extends StatefulWidget {
// //   final String tripId;
// //   final String carId;
// //   final String renterId;
// //   final String rentalId;
// //
// //   const LiveLocationMapScreen({
// //     super.key,
// //     required this.tripId,
// //     required this.carId,
// //     required this.renterId,
// //     required this.rentalId,
// //
// //   });
// //
// //   @override
// //   State<LiveLocationMapScreen> createState() => _LiveLocationMapScreenState();
// // }
// //
// // class _LiveLocationMapScreenState extends State<LiveLocationMapScreen> {
// //   final PopupController _popupController = PopupController();
// //   LatLng? _currentLocation;
// //   bool _isLoading = true;
// //   bool _isRefreshing = false;
// //   String? _errorMessage;
// //
// //   // لا يوجد موقع افتراضي حقيقي، فقط إذا لم تتوفر بيانات
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadLatestLocation();
// //   }
// //
// //   Future<void> _loadLatestLocation() async {
// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = null;
// //     });
// //
// //     try {
// //       // استبدل baseUrl بالمتغير المناسب في مشروعك
// //       final baseUrl = 'https://reject-guests-creek-friday.trycloudflare.com'; // TODO: غيّر هذا حسب مشروعك
// //       final url = Uri.parse('$baseUrl/api/selfdrive-rentals/${widget.rentalId}/request_location/');
// //       final response = await http.post(url);
// //
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         final lat = data['latitude'] as num?;
// //         final lng = data['longitude'] as num?;
// //         if (lat != null && lng != null) {
// //           setState(() {
// //             _currentLocation = LatLng(lat.toDouble(), lng.toDouble());
// //             _isLoading = false;
// //           });
// //         } else {
// //           setState(() {
// //             _currentLocation = null;
// //             _isLoading = false;
// //             _errorMessage = 'لا يوجد موقع متاح حالياً.';
// //           });
// //         }
// //       } else {
// //         setState(() {
// //           _currentLocation = null;
// //           _isLoading = false;
// //           _errorMessage = 'فشل في جلب الموقع من السيرفر.';
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _errorMessage = 'خطأ أثناء جلب الموقع: $e';
// //         _currentLocation = null;
// //         _isLoading = false;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Live Car Location'),
// //         backgroundColor: AppColors.primary,
// //         foregroundColor: Colors.white,
// //         centerTitle: true,
// //         elevation: 0,
// //         actions: [
// //           if (_isRefreshing)
// //             const Padding(
// //               padding: EdgeInsets.all(16.0),
// //               child: SizedBox(
// //                 width: 20,
// //                 height: 20,
// //                 child: CircularProgressIndicator(
// //                   strokeWidth: 2,
// //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //       body: _isLoading
// //           ? const Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   CircularProgressIndicator(
// //                     valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
// //                   ),
// //                   SizedBox(height: 16),
// //                   Text('جاري تحميل الموقع...'),
// //                 ],
// //               ),
// //             )
// //           : _currentLocation == null
// //               ? Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(
// //                         Icons.location_off,
// //                         size: 64,
// //                         color: Colors.grey[400],
// //                       ),
// //                       const SizedBox(height: 16),
// //                       Text(
// //                         'الموقع غير متوفر',
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.grey[600],
// //                         ),
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Text(
// //                         _errorMessage ?? '',
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           color: Colors.grey[500],
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                       const SizedBox(height: 24),
// //                       ElevatedButton(
// //                         onPressed: _loadLatestLocation,
// //                         child: const Text('إعادة المحاولة'),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : Stack(
// //                   children: [
// //                     // Flutter Map
// //                     FlutterMap(
// //                       options: MapOptions(
// //                         initialCenter: _currentLocation!,
// //                         initialZoom: 15.0,
// //                         onTap: (_, __) => _popupController.hideAllPopups(),
// //                       ),
// //                       children: [
// //                         TileLayer(
// //                           urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
// //                           subdomains: const ['a', 'b', 'c'],
// //                         ),
// //                         // Car location marker
// //                         MarkerLayer(
// //                           markers: [
// //                             Marker(
// //                               point: _currentLocation!,
// //                               width: 50,
// //                               height: 50,
// //                               child: GestureDetector(
// //                                 onTap: () => _popupController.showPopupsOnlyFor([
// //                                   Marker(
// //                                     point: _currentLocation!,
// //                                     width: 50,
// //                                     height: 50,
// //                                     child: const SizedBox.shrink(),
// //                                   ),
// //                                 ]),
// //                                 child: Container(
// //                                   decoration: BoxDecoration(
// //                                     color: AppColors.primary,
// //                                     shape: BoxShape.circle,
// //                                     border: Border.all(
// //                                       color: Colors.white,
// //                                       width: 3,
// //                                     ),
// //                                     boxShadow: [
// //                                       BoxShadow(
// //                                         color: AppColors.primary.withOpacity(0.3),
// //                                         blurRadius: 10,
// //                                         spreadRadius: 2,
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   child: const Icon(
// //                                     Icons.directions_car,
// //                                     color: Colors.white,
// //                                     size: 24,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         // Popup for car location
// //                         PopupMarkerLayer(
// //                           options: PopupMarkerLayerOptions(
// //                             markers: [
// //                               Marker(
// //                                 point: _currentLocation!,
// //                                 width: 50,
// //                                 height: 50,
// //                                 child: const SizedBox.shrink(),
// //                               ),
// //                             ],
// //                             popupController: _popupController,
// //                             popupDisplayOptions: PopupDisplayOptions(
// //                               builder: (ctx, marker) {
// //                                 return Container(
// //                                   padding: const EdgeInsets.all(16),
// //                                   decoration: BoxDecoration(
// //                                     color: Colors.white,
// //                                     borderRadius: BorderRadius.circular(12),
// //                                     boxShadow: [
// //                                       BoxShadow(
// //                                         color: Colors.black.withOpacity(0.1),
// //                                         blurRadius: 10,
// //                                         offset: const Offset(0, 2),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   child: Column(
// //                                     mainAxisSize: MainAxisSize.min,
// //                                     children: [
// //                                       Row(
// //                                         children: [
// //                                           Icon(
// //                                             Icons.directions_car,
// //                                             color: AppColors.primary,
// //                                             size: 20,
// //                                           ),
// //                                           const SizedBox(width: 8),
// //                                           const Text(
// //                                             'سيارتك',
// //                                             style: TextStyle(
// //                                               fontSize: 16,
// //                                               fontWeight: FontWeight.bold,
// //                                             ),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                       const SizedBox(height: 8),
// //                                       Text(
// //                                         'Lat: ${_currentLocation?.latitude.toStringAsFixed(6) ?? 'N/A'}',
// //                                         style: TextStyle(
// //                                           fontSize: 12,
// //                                           color: Colors.grey[600],
// //                                         ),
// //                                       ),
// //                                       Text(
// //                                         'Lng: ${_currentLocation?.longitude.toStringAsFixed(6) ?? 'N/A'}',
// //                                         style: TextStyle(
// //                                           fontSize: 12,
// //                                           color: Colors.grey[600],
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 );
// //                               },
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     // Location info card
// //                     Positioned(
// //                       top: 20,
// //                       left: 20,
// //                       right: 20,
// //                       child: Container(
// //                         padding: const EdgeInsets.all(16),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(12),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withOpacity(0.1),
// //                               blurRadius: 10,
// //                               offset: const Offset(0, 2),
// //                             ),
// //                           ],
// //                         ),
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Row(
// //                               children: [
// //                                 Icon(
// //                                   Icons.location_on,
// //                                   color: AppColors.primary,
// //                                   size: 20,
// //                                 ),
// //                                 const SizedBox(width: 8),
// //                                 const Text(
// //                                   'موقع السيارة',
// //                                   style: TextStyle(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             const SizedBox(height: 8),
// //                             Text(
// //                               'Lat: ${_currentLocation?.latitude.toStringAsFixed(6) ?? 'N/A'}',
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: Colors.grey[600],
// //                               ),
// //                             ),
// //                             Text(
// //                               'Lng: ${_currentLocation?.longitude.toStringAsFixed(6) ?? 'N/A'}',
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: Colors.grey[600],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //       floatingActionButton: _currentLocation != null
// //           ? FloatingActionButton(
// //               onPressed: _isRefreshing ? null : _loadLatestLocation,
// //               backgroundColor: AppColors.primary,
// //               foregroundColor: Colors.white,
// //               child: _isRefreshing
// //                   ? const SizedBox(
// //                       width: 20,
// //                       height: 20,
// //                       child: CircularProgressIndicator(
// //                         strokeWidth: 2,
// //                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                       ),
// //                     )
// //                   : const Icon(Icons.refresh),
// //             )
// //           : null,
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _popupController.dispose();
// //     super.dispose();
// //   }
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../../../config/themes/app_colors.dart';
//
// class LiveLocationMapScreen extends StatefulWidget {
//   final String tripId;
//   final String carId;
//   final String renterId;
//   final String rentalId;
//
//   const LiveLocationMapScreen({
//     super.key,
//     required this.tripId,
//     required this.carId,
//     required this.renterId,
//     required this.rentalId,
//   });
//
//   @override
//   State<LiveLocationMapScreen> createState() => _LiveLocationMapScreenState();
// }
//
// class _LiveLocationMapScreenState extends State<LiveLocationMapScreen> {
//   final PopupController _popupController = PopupController();
//   LatLng? _currentLocation;
//   bool _isLoading = true;
//   bool _isRefreshing = false;
//   String? _errorMessage;
//
//   // Default location (Ramsis, Cairo) as fallback
//   static const LatLng _defaultLocation = LatLng(30.06263, 31.24967);
//
//   @override
//   void initState() {
//     super.initState();
//     _loadLatestLocation();
//   }
//
//   Future<void> _loadLatestLocation() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       // First, try to get the latest location from Firestore
//       final locationDoc = await FirebaseFirestore.instance
//           .collection('car_locations')
//           .where('carId', isEqualTo: widget.carId)
//           .orderBy('timestamp', descending: true)
//           .limit(1)
//           .get();
//
//       if (locationDoc.docs.isNotEmpty) {
//         final locationData = locationDoc.docs.first.data();
//         final lat = locationData['lat'] as double;
//         final lng = locationData['lng'] as double;
//
//         setState(() {
//           _currentLocation = LatLng(lat, lng);
//           _isLoading = false;
//         });
//       } else {
//         // If no location in database, use default location
//         setState(() {
//           _currentLocation = _defaultLocation;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error loading location: $e';
//         _currentLocation = _defaultLocation;
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _refreshLocation() async {
//     setState(() {
//       _isRefreshing = true;
//       _errorMessage = null;
//     });
//
//     try {
//       // Simulate getting new location (in real app, this would come from the car's GPS)
//       // For now, we'll generate a random location near the current one
//       final randomLat = _currentLocation?.latitude ?? _defaultLocation.latitude;
//       final randomLng = _currentLocation?.longitude ?? _defaultLocation.longitude;
//
//       final newLat = randomLat + (0.001 * (DateTime.now().millisecondsSinceEpoch % 100 - 50));
//       final newLng = randomLng + (0.001 * (DateTime.now().millisecondsSinceEpoch % 100 - 50));
//
//       final newLocation = LatLng(newLat, newLng);
//
//       // Save to Firestore
//       await FirebaseFirestore.instance.collection('car_locations').add({
//         'carId': widget.carId,
//         'tripId': widget.tripId,
//         'renterId': widget.renterId,
//         'lat': newLat,
//         'lng': newLng,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       setState(() {
//         _currentLocation = newLocation;
//         _isRefreshing = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Location updated successfully'),
//           backgroundColor: AppColors.green,
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error updating location: $e';
//         _isRefreshing = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error updating location: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Live Car Location'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           if (_isRefreshing)
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//             ),
//             SizedBox(height: 16),
//             Text('Loading location...'),
//           ],
//         ),
//       )
//           : _errorMessage != null && _currentLocation == null
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.location_off,
//               size: 64,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Location not available',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _errorMessage!,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[500],
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _loadLatestLocation,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       )
//           : Stack(
//         children: [
//           // Flutter Map
//           FlutterMap(
//             options: MapOptions(
//               initialCenter: _currentLocation ?? _defaultLocation,
//               initialZoom: 15.0,
//               onTap: (_, __) => _popupController.hideAllPopups(),
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 subdomains: const ['a', 'b', 'c'],
//               ),
//               // Car location marker
//               if (_currentLocation != null)
//                 MarkerLayer(
//                   markers: [
//                     Marker(
//                       point: _currentLocation!,
//                       width: 50,
//                       height: 50,
//                       child: GestureDetector(
//                         onTap: () => _popupController.showPopupsOnlyFor([
//                           Marker(
//                             point: _currentLocation!,
//                             width: 50,
//                             height: 50,
//                             child: const SizedBox.shrink(),
//                           ),
//                         ]),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: AppColors.primary,
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.white,
//                               width: 3,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: AppColors.primary.withOpacity(0.3),
//                                 blurRadius: 10,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                           child: const Icon(
//                             Icons.directions_car,
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               // Popup for car location
//               PopupMarkerLayer(
//                 options: PopupMarkerLayerOptions(
//                   markers: _currentLocation != null
//                       ? [
//                     Marker(
//                       point: _currentLocation!,
//                       width: 50,
//                       height: 50,
//                       child: const SizedBox.shrink(),
//                     ),
//                   ]
//                       : [],
//                   popupController: _popupController,
//                   popupDisplayOptions: PopupDisplayOptions(
//                     builder: (ctx, marker) {
//                       return Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 10,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.directions_car,
//                                   color: AppColors.primary,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 const Text(
//                                   'Your Car',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Lat: ${_currentLocation?.latitude.toStringAsFixed(6) ?? 'N/A'}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             Text(
//                               'Lng: ${_currentLocation?.longitude.toStringAsFixed(6) ?? 'N/A'}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           // Location info card
//           Positioned(
//             top: 20,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.location_on,
//                         color: AppColors.primary,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       const Text(
//                         'Car Location',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Lat: ${_currentLocation?.latitude.toStringAsFixed(6) ?? 'N/A'}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   Text(
//                     'Lng: ${_currentLocation?.longitude.toStringAsFixed(6) ?? 'N/A'}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: _currentLocation != null
//           ? FloatingActionButton(
//         onPressed: _isRefreshing ? null : _refreshLocation,
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         child: _isRefreshing
//             ? const SizedBox(
//           width: 20,
//           height: 20,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         )
//             : const Icon(Icons.refresh),
//       )
//           : null,
//     );
//   }
//
//   @override
//   void dispose() {
//     _popupController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/themes/app_colors.dart';

class LiveLocationMapScreen extends StatefulWidget {
  final String tripId;
  final String carId;
  final String renterId;
  final String rentalId;

  const LiveLocationMapScreen({
    super.key,
    required this.tripId,
    required this.carId,
    required this.renterId,
    required this.rentalId,
  });

  @override
  State<LiveLocationMapScreen> createState() => _LiveLocationMapScreenState();
}

class _LiveLocationMapScreenState extends State<LiveLocationMapScreen> {
  final PopupController _popupController = PopupController();
  LatLng? _currentLocation;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Default location (Ramsis, Cairo) as fallback
  static const LatLng _defaultLocation = LatLng(30.06263, 31.24967);

  @override
  void initState() {
    super.initState();
    _loadLatestLocation();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _loadLatestLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = 'https://brandon-moderators-thorough-strict.trycloudflare.com/api';
      final url = Uri.parse('$baseUrl/selfdrive-rentals/${widget.rentalId}/request_location/');
      final token = await _getToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'لم يتم العثور على التوكن. يرجى تسجيل الدخول مجددًا.';
        });
        return;
      }
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lat = data['latitude'] as num?;
        final lng = data['longitude'] as num?;
        if (lat != null && lng != null) {
          setState(() {
            _currentLocation = LatLng(lat.toDouble(), lng.toDouble());
            _isLoading = false;
          });
        } else {
          setState(() {
            _currentLocation = null;
            _isLoading = false;
            _errorMessage = 'لا يوجد موقع متاح حالياً.';
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() {
          _currentLocation = null;
          _isLoading = false;
          _errorMessage = 'انتهت صلاحية الجلسة أو لا يوجد صلاحية. يرجى تسجيل الدخول مجددًا.';
        });
      } else {
        setState(() {
          _currentLocation = null;
          _isLoading = false;
          _errorMessage = 'فشل في جلب الموقع من السيرفر.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ أثناء جلب الموقع: $e';
        _currentLocation = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = 'https://brandon-moderators-thorough-strict.trycloudflare.com/api';
      final url = Uri.parse('$baseUrl/selfdrive-rentals/${widget.rentalId}/request_location/');
      final token = await _getToken();
      if (token == null) {
        setState(() {
          _isRefreshing = false;
          _errorMessage = 'لم يتم العثور على التوكن. يرجى تسجيل الدخول مجددًا.';
        });
        return;
      }
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lat = data['latitude'] as num?;
        final lng = data['longitude'] as num?;
        if (lat != null && lng != null) {
          setState(() {
            _currentLocation = LatLng(lat.toDouble(), lng.toDouble());
            _isRefreshing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الموقع بنجاح'),
              backgroundColor: AppColors.green,
            ),
          );
        } else {
          setState(() {
            _isRefreshing = false;
            _errorMessage = 'لا يوجد موقع متاح حالياً.';
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() {
          _isRefreshing = false;
          _errorMessage = 'انتهت صلاحية الجلسة أو لا يوجد صلاحية. يرجى تسجيل الدخول مجددًا.';
        });
      } else {
        setState(() {
          _isRefreshing = false;
          _errorMessage = 'فشل في جلب الموقع من السيرفر.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ أثناء جلب الموقع: $e';
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ أثناء تحديث الموقع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Car Location'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text('Loading location...'),
          ],
        ),
      )
          : _errorMessage != null && _currentLocation == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Location not available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadLatestLocation,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          // Flutter Map
          FlutterMap(
            options: MapOptions(
              initialCenter: _currentLocation ?? _defaultLocation,
              initialZoom: 15.0,
              onTap: (_, __) => _popupController.hideAllPopups(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              // Car location marker
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _popupController.showPopupsOnlyFor([
                          Marker(
                            point: _currentLocation!,
                            width: 50,
                            height: 50,
                            child: const SizedBox.shrink(),
                          ),
                        ]),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              // Popup for car location
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  markers: _currentLocation != null
                      ? [
                    Marker(
                      point: _currentLocation!,
                      width: 50,
                      height: 50,
                      child: const SizedBox.shrink(),
                    ),
                  ]
                      : [],
                  popupController: _popupController,
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (ctx, marker) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Your Car',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lat: ${_currentLocation?.latitude.toStringAsFixed(6) ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Lng: ${_currentLocation?.longitude.toStringAsFixed(6) ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // Location info card
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Car Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lat: ${_currentLocation?.latitude.toStringAsFixed(6) ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Lng: ${_currentLocation?.longitude.toStringAsFixed(6) ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentLocation != null
          ? FloatingActionButton(
        onPressed: _isRefreshing ? null : _refreshLocation,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: _isRefreshing
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Icon(Icons.refresh),
      )
          : null,
    );
  }

  @override
  void dispose() {
    _popupController.dispose();
    super.dispose();
  }
}