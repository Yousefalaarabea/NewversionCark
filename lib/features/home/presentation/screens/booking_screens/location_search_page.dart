import 'package:flutter/material.dart';
import '../../../../../core/utils/place_suggestions_service.dart';

class LocationSearchPage extends StatefulWidget {
  final String apiKey;
  const LocationSearchPage({Key? key, required this.apiKey}) : super(key: key);

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<PlaceSuggestion> _suggestions = [];
  bool _isLoading = false;
  PlaceSuggestionsService? _suggestionsService;

  @override
  void initState() {
    super.initState();
    _suggestionsService = PlaceSuggestionsService(widget.apiKey);
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onTextChanged() async {
    final text = _searchController.text.trim();
    if (text.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _isLoading = true);
    final suggestions = await _suggestionsService!.fetchSuggestions(text);
    if (mounted) {
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    }
  }

  Future<void> _onSuggestionTap(PlaceSuggestion suggestion) async {
    setState(() => _isLoading = true);
    final details = await _suggestionsService!.fetchPlaceDetails(suggestion.placeId);
    setState(() => _isLoading = false);
    if (details != null) {
      Navigator.of(context).pop({
        'name': details['name'],
        'address': details['address'],
        'lat': details['lat'],
        'lng': details['lng'],
      });
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!_isLoading && _suggestions.isEmpty && _searchController.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No results found.'),
            ),
          if (_suggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(suggestion.description),
                    onTap: () => _onSuggestionTap(suggestion),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
} 