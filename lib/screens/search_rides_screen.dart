import 'package:co_rider/models/location_suggestion.dart';
import 'package:co_rider/screens/ride_results_screen.dart';
import 'package:co_rider/services/ride_service.dart';
import 'package:co_rider/theme/theme_controller.dart';
import 'package:co_rider/widgets/location_autocomplete_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchRidesScreen extends StatefulWidget {
  const SearchRidesScreen({super.key});

  @override
  State<SearchRidesScreen> createState() => _SearchRidesScreenState();
}

class _SearchRidesScreenState extends State<SearchRidesScreen> {
  final RideService _rideService = RideService();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  LocationSuggestion? _fromLocation;
  LocationSuggestion? _toLocation;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  int _timeWindowMinutes = 60;
  int _seats = 1;
  bool _isSearching = false;

  // Internal-only radius filter (not shown in UI)
  static const double _internalRadiusKm = 2.0;

  @override
  void initState() {
    super.initState();

    _fromController.addListener(() {
      if (_fromLocation != null && _fromController.text != _fromLocation!.name) {
        setState(() => _fromLocation = null);
      }
    });

    _toController.addListener(() {
      if (_toLocation != null && _toController.text != _toLocation!.name) {
        setState(() => _toLocation = null);
      }
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  DateTime? _selectedDepartureDateTime() {
    if (_selectedDate == null || _selectedTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedDate = pickedDate;
      _selectedTime = pickedTime;
    });
  }

  Future<void> _searchRides() async {
    final departure = _selectedDepartureDateTime();
    if (_fromLocation == null || _toLocation == null || departure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select from, to and departure date/time first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      final rides = await _rideService.searchRides(
        source: _fromLocation!,
        destination: _toLocation!,
        departureTime: departure,
        maxDistanceKm: _internalRadiusKm,
        timeWindow: Duration(minutes: _timeWindowMinutes),
        requiredSeats: _seats,
      );

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/ride_results',
        arguments: RideResultsArgs(
          rides: rides,
          from: _fromLocation!,
          to: _toLocation!,
          departureTime: departure,
          timeWindowMinutes: _timeWindowMinutes,
          seats: _seats,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF1E293B) : Colors.grey[200]!;
    final surfaceColor = isDark ? const Color(0xFF1C2536) : Colors.white;
    final hintColor = Colors.grey[500]!;
    final departure = _selectedDepartureDateTime();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Search Rides'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ThemeController().toggleTheme(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        Icon(
                          Icons.radio_button_unchecked,
                          size: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Container(
                          width: 2,
                          height: 80,
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          LocationAutocompleteField(
                            label: 'Leaving From',
                            controller: _fromController,
                            prefixIcon: Icons.my_location,
                            onSelected: (s) => setState(() => _fromLocation = s),
                          ),
                          const SizedBox(height: 16),
                          LocationAutocompleteField(
                            label: 'Going To',
                            controller: _toController,
                            prefixIcon: Icons.location_on,
                            prefixIconColor: Colors.redAccent,
                            onSelected: (s) => setState(() => _toLocation = s),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: 20),
                const Text(
                  'Departure Time',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDateTime,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF101622) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          departure == null
                              ? 'Select Date & Time'
                              : DateFormat('d/M/y • h:mm a').format(departure),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: departure == null ? hintColor : null,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_month, color: hintColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildSimpleDropdown<int>(
                        label: 'Time Window',
                        value: _timeWindowMinutes,
                        items: const [15, 30, 60, 90, 120],
                        textBuilder: (v) => '±$v min',
                        onChanged: (v) => setState(() => _timeWindowMinutes = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSimpleDropdown<int>(
                        label: 'Passengers',
                        value: _seats,
                        items: const [1, 2, 3, 4],
                        textBuilder: (v) => '$v',
                        onChanged: (v) => setState(() => _seats = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isSearching ? null : _searchRides,
            icon: _isSearching
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: Text(_isSearching ? 'Searching...' : 'Find Rides'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) textBuilder,
    required void Function(T) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF1E293B) : Colors.grey[200]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101622) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(textBuilder(item)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
