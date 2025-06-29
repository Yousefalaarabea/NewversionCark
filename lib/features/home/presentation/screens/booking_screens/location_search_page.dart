import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'dart:async'; // لاستخدام Timer للـ debounce

class MapLocationSearchPage extends StatefulWidget {
  const MapLocationSearchPage({Key? key}) : super(key: key);

  @override
  State<MapLocationSearchPage> createState() => _MapLocationSearchPageState();
}

class _MapLocationSearchPageState extends State<MapLocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final PopupController _popupController = PopupController();

  // قائمة لتخزين نتائج البحث النهائية (التي تظهر على الخريطة)
  List<Place> _searchResults = [];

  // قائمة لتخزين الاقتراحات أثناء الكتابة
  List<Place> _suggestions = [];

  Place? _selectedLocation;
  bool _isLoadingSearch = false; // حالة التحميل للبحث النهائي
  bool _isLoadingSuggestions = false; // حالة التحميل للاقتراحات

  // لـ Debounce: لتأخير طلبات البحث عن الاقتراحات
  Timer? _debounce;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // الاستماع لتغييرات النص لجلب الاقتراحات
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController
        .removeListener(_onSearchTextChanged); // إزالة الـ listener
    _searchController.dispose();
    _popupController.dispose();
    _debounce?.cancel(); // إلغاء الـ debounce timer إذا كان نشطًا
    super.dispose();
  }

  // دالة تُستدعى عند كل تغيير في نص شريط البحث
  void _onSearchTextChanged() {
    if (_debounce?.isActive ?? false)
      _debounce!.cancel(); // إلغاء الـ timer السابق

    // إعداد timer جديد لتأخير البحث عن الاقتراحات بـ 500 ملي ثانية (نصف ثانية)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _fetchSuggestions(_searchController.text);
      } else {
        // إذا كان شريط البحث فارغًا، نمسح الاقتراحات
        setState(() {
          _suggestions = [];
          _errorMessage = null;
        });
      }
    });
  }

  // دالة لجلب الاقتراحات أثناء الكتابة
  Future<void> _fetchSuggestions(String query) async {
    setState(() {
      _isLoadingSuggestions = true;
      _suggestions = []; // مسح الاقتراحات القديمة
      _errorMessage = null;
    });

    try {
      final suggestions = await Nominatim.searchByName(
        query: query,
        limit: 5,
        // عدد أقل من الاقتراحات
        addressDetails: false,
        // لا نحتاج تفاصيل كاملة للاقتراحات
        extraTags: false,
        nameDetails: false,
      );

      setState(() {
        _suggestions = suggestions;
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      print('Error fetching suggestions: $e');
      setState(() {
        _isLoadingSuggestions = false;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  // دالة للبحث النهائي وتحديث الخريطة
  Future<void> _searchAndDisplayLocation(String query) async {
    setState(() {
      _isLoadingSearch = true; // تفعيل حالة التحميل للبحث النهائي
      _searchResults = []; // مسح النتائج السابقة على الخريطة
      _selectedLocation = null;
      _suggestions = []; // مسح الاقتراحات عند إجراء بحث نهائي
      _popupController.hideAllPopups(); // إخفاء أي نوافذ منبثقة
      _errorMessage = null;
    });

    try {
      final results = await Nominatim.searchByName(
        query: query,
        limit: 10,
        addressDetails: true,
        extraTags: true,
        nameDetails: true,
      );

      setState(() {
        _searchResults = results;
        _isLoadingSearch = false;
        if (_searchResults.isNotEmpty) {
          _selectedLocation = _searchResults.first;
        }
      });
    } catch (e) {
      print('Error searching location: $e');
      setState(() {
        _isLoadingSearch = false;
        _errorMessage = _getErrorMessage(e);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('FormatException') ||
        error.toString().contains('<html>')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return 'No internet connection. Please check your network.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  void _selectLocation(Place location) {
    setState(() {
      _selectedLocation = location;
    });
    _popupController.showPopupsOnlyFor([
      Marker(
        point: LatLng(location.lat, location.lon),
        width: 40,
        height: 40,
        child: const SizedBox.shrink(),
      ),
    ]);
  }

  void _retrySearch() {
    if (_searchController.text.isNotEmpty) {
      _searchAndDisplayLocation(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'latLng':
                      LatLng(_selectedLocation!.lat, _selectedLocation!.lon),
                  'address': _selectedLocation!.displayName,
                });
              },
              child: const Text('Confirm'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _suggestions = [];
                            _searchResults = [];
                            _selectedLocation = null;
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: _searchAndDisplayLocation,
            ),
          ),
          // عرض رسالة الخطأ إذا كانت موجودة
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: _retrySearch,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          // عرض مؤشر التحميل للاقتراحات
          if (_isLoadingSuggestions)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),

          // عرض قائمة الاقتراحات (تظهر فقط إذا كان هناك نص في البحث ولم يتم إجراء بحث نهائي بعد)
          if (!_isLoadingSuggestions &&
              _suggestions.isNotEmpty &&
              _searchResults.isEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.blue),
                    title: Text(
                      suggestion.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      _searchController.text = suggestion.displayName;
                      _searchAndDisplayLocation(suggestion.displayName);
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),

          // عرض مؤشر التحميل للبحث النهائي
          if (_isLoadingSearch)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          // عرض رسالة "لا توجد نتائج" إذا انتهى البحث النهائي ولم يتم العثور على شيء
          if (!_isLoadingSearch &&
              _searchResults.isEmpty &&
              _searchController.text.isNotEmpty &&
              _suggestions.isEmpty &&
              _errorMessage == null)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No results found for your search.',
                style: TextStyle(color: Colors.grey),
              ),
            ),

          // عرض الخريطة فقط إذا كانت هناك نتائج بحث نهائية
          if (_searchResults.isNotEmpty)
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    _searchResults[0].lat,
                    _searchResults[0].lon,
                  ),
                  initialZoom: 13.0,
                  onTap: (_, __) => _popupController.hideAllPopups(),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  // MarkerLayer لعرض الأيقونات على الخريطة
                  MarkerLayer(
                    markers: _searchResults.map((loc) {
                      final isSelected = _selectedLocation == loc;
                      return Marker(
                        point: LatLng(loc.lat, loc.lon),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _selectLocation(loc),
                          child: Icon(
                            Icons.location_on,
                            color: isSelected ? Colors.red : Colors.blue,
                            size: isSelected ? 40 : 32,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  // PopupMarkerLayer لعرض النوافذ المنبثقة عند النقر على الماركر
                  PopupMarkerLayer(
                    options: PopupMarkerLayerOptions(
                      markers: _searchResults.map((loc) {
                        return Marker(
                          point: LatLng(loc.lat, loc.lon),
                          width: 40,
                          height: 40,
                          child: const SizedBox.shrink(),
                        );
                      }).toList(),
                      popupController: _popupController,
                      popupDisplayOptions: PopupDisplayOptions(
                        builder: (ctx, marker) {
                          final loc = _searchResults.firstWhere((l) =>
                              l.lat == marker.point.latitude &&
                              l.lon == marker.point.longitude);
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    loc.displayName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pop({
                                        'latLng': LatLng(loc.lat, loc.lon),
                                        'address': loc.displayName,
                                      });
                                    },
                                    icon: const Icon(Icons.check),
                                    label: const Text('Select Location'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
