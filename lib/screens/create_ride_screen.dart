import 'dart:ui';
import 'package:co_rider/models/ride.dart';
import 'package:co_rider/models/location_suggestion.dart';
import 'package:co_rider/services/auth_service.dart';
import 'package:co_rider/services/ride_service.dart';
import 'package:co_rider/theme/theme_controller.dart';
import 'package:co_rider/widgets/location_autocomplete_field.dart';
import 'package:flutter/material.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({super.key});

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final TextEditingController _fromController = TextEditingController(text: 'Downtown Market St.');
  final TextEditingController _toController = TextEditingController();
  
  final RideService _rideService = RideService();
  final AuthService _authService = AuthService();

  // Form State
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _selectedSeats = 3;
  double _price = 24.0;
  bool _noSmoking = false;
  bool _petsAllowed = true;
  bool _music = false;

  LocationSuggestion? _sourceLocation;
  LocationSuggestion? _destinationLocation;

  bool _isLoading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _fromController.addListener(() {
      if (_sourceLocation != null && _fromController.text != _sourceLocation!.name) {
        setState(() {
          _sourceLocation = null;
          _validateForm();
        });
      } else {
        _validateForm();
      }
    });
    _toController.addListener(() {
      if (_destinationLocation != null && _toController.text != _destinationLocation!.name) {
        setState(() {
          _destinationLocation = null;
          _validateForm();
        });
      } else {
        _validateForm();
      }
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isValid = _fromController.text.isNotEmpty && 
                 _toController.text.isNotEmpty &&
                 _sourceLocation != null &&
                 _destinationLocation != null &&
                 _selectedDate != null &&
                 _selectedTime != null;
    });
  }

  Future<DateTime?> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _validateForm();
    }
    return picked;
  }

  Future<TimeOfDay?> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      _validateForm();
    }
    return picked;
  }

  Future<void> _submitRide() async {
    if (!_isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'User not logged in';
      }

      // Combine date and time
      final DateTime departureTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final ride = Ride(
        driverId: user.id,
        sourceName: _sourceLocation!.name,
        sourceLat: _sourceLocation!.lat, 
        sourceLon: _sourceLocation!.lon,
        destinationName: _destinationLocation!.name,
        destinationLat: _destinationLocation!.lat,
        destinationLon: _destinationLocation!.lon,
        departureTime: departureTime,
        totalSeats: _selectedSeats,
        availableSeats: _selectedSeats,
        status: RideStatus.active,
      );

      await _rideService.createRide(ride);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride published successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Go back to role selection or dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating ride: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = isDark ? const Color(0xFF1C2536) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : Colors.grey[200]!;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final hintColor = Colors.grey[400]!;


    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Cancel'),
                      ),
                      Expanded(
                        child: Text(
                          'Create Ride',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                               ),
                        ),
                      ),
                       // Theme Toggle
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                        onPressed: () {
                          ThemeController().toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 100), // Space for bottom bar
                    children: [
                      // Map Preview (Static for now)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: 192,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBvjgYTzHdX-m4g8Bd-XMMZkMoiQ1TC-nlTwfXBZh4zdyTT174A4cZpe4GQUiCBAzFZC26i-kjdCAB9zKW7L5z2sCQGSG06ruVXUCs4gJsvUo18RZVmjKh23RkscAL-IpJdyPOYZVB4esWXqK06_dQnMgNYMxrqFrlvhhnG0W46AwdzrkH0aIJxX0knZjpwAktKJYOUSvTpRv68FF0L3FZ-9ha8XvWwOUhaIKKTzk1tkLQdQGjucK6WBrw5_9fDChpNjkEsF8o_XzlI'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.05),
                                      Colors.black.withValues(alpha: 0.2),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_location,
                                        size: 16,
                                        color: textColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Edit Route',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Form Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Route Inputs
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      Icon(Icons.radio_button_unchecked,
                                          size: 12,
                                          color: Theme.of(context).colorScheme.primary),
                                      Container(
                                        width: 2,
                                        height: 80, // Expanded height for text fields
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                      ),
                                      Icon(Icons.location_on,
                                          size: 20,
                                          color: Theme.of(context).colorScheme.primary),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          LocationAutocompleteField(
                                            label: 'Leaving From',
                                            controller: _fromController,
                                            prefixIcon: Icons.my_location, // Or just use default
                                            onSelected: (suggestion) {
                                              setState(() {
                                                _sourceLocation = suggestion;
                                                _validateForm();
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          LocationAutocompleteField(
                                            label: 'Going To',
                                            controller: _toController,
                                            prefixIcon: Icons.location_on,
                                            prefixIconColor: Colors.redAccent,
                                            onSelected: (suggestion) {
                                              setState(() {
                                                _destinationLocation = suggestion;
                                                _validateForm();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Divider(color: borderColor, height: 1),
                              const SizedBox(height: 24),
                              
                              // Date & Time
                              _buildLabel(context, 'Departure Time'),
                              InkWell(
                                onTap: () async {
                                  final date = await _selectDate();
                                  if (date != null) {
                                    await _selectTime();
                                  }
                                },
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
                                        _selectedDate == null || _selectedTime == null
                                            ? 'Select Date & Time'
                                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} at ${_selectedTime!.format(context)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: _selectedDate == null ? hintColor : textColor), 
                                      ),
                                      const Spacer(),
                                      Icon(Icons.calendar_month, color: hintColor),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Seats & Price Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel(context, 'Passengers'),
                                        Container(
                                          height: 46,
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF101622) : const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: borderColor),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildSeatOption(context, '1', 1),
                                              _buildSeatOption(context, '2', 2),
                                              _buildSeatOption(context, '3', 3),
                                              _buildSeatOption(context, '4', 4),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel(context, 'Price'),
                                        Container(
                                          height: 48, // Match visual height roughly
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF101622) : const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: borderColor),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Row(
                                            children: [
                                              Text(
                                                '\$',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: hintColor,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: TextField(
                                                  keyboardType: TextInputType.number,
                                                  controller: TextEditingController(text: _price.toStringAsFixed(0)),
                                                  onChanged: (val) {
                                                    setState(() {
                                                      _price = double.tryParse(val) ?? 0;
                                                    });
                                                  },
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                    contentPadding: EdgeInsets.zero,
                                                  ),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Preferences
                              _buildLabel(context, 'Preferences'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  InkWell(
                                    onTap: () => setState(() => _noSmoking = !_noSmoking),
                                    child: _buildChip(context, Icons.smoke_free, 'No Smoking', _noSmoking)
                                  ),
                                  InkWell(
                                    onTap: () => setState(() => _petsAllowed = !_petsAllowed),
                                    child: _buildChip(context, Icons.pets, 'Pets Allowed', _petsAllowed)
                                  ),
                                  InkWell(
                                    onTap: () => setState(() => _music = !_music),
                                    child: _buildChip(context, Icons.music_note, 'Music', _music)
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Info Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info,
                              size: 18,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                          const SizedBox(width: 8),
                          Text(
                            'Fees may apply based on ride distance',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
                    border: Border(
                      top: BorderSide(
                        color: borderColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton(
                      onPressed: _isValid && !_isLoading
                          ? _submitRide
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _isValid ? 4 : 0,
                        shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Publish Ride',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context,
      {required String label, required TextEditingController controller, String? placeholder}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF1E293B) : Colors.grey[200]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[400],
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Removing container padding for TextField
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101622) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0D121B),
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildSeatOption(BuildContext context, String text, int seatCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedSeats == seatCount;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSeats = seatCount;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Theme.of(context).colorScheme.primary : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? (isDark ? Colors.white : Theme.of(context).colorScheme.primary)
                  : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
      BuildContext context, IconData icon, String label, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? primaryColor
                  : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }
}
