import 'dart:ui';
import 'package:co_rider/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({super.key});

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final TextEditingController _fromController = TextEditingController(text: 'Downtown Market St.');
  final TextEditingController _toController = TextEditingController();
  
  // Simple state to track form validity
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _fromController.addListener(_validateForm);
    _toController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isValid = _fromController.text.isNotEmpty && _toController.text.isNotEmpty;
    });
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
                      // Map Preview
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: 192,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
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
                                      Colors.black.withOpacity(0.05),
                                      Colors.black.withOpacity(0.2),
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
                                        color: Colors.black.withOpacity(0.1),
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
                                        _buildInput(
                                          context,
                                          label: 'Leaving From',
                                          controller: _fromController,
                                          placeholder: 'Enter location',
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInput(
                                          context,
                                          label: 'Going To',
                                          controller: _toController,
                                          placeholder: 'Enter destination',
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
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF101622) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: borderColor),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    // Placeholder for date picker
                                    Text(
                                      'Select Date & Time', // Or leave empty/ use value if provided
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: hintColor), 
                                    ),
                                    const Spacer(),
                                    Icon(Icons.calendar_month, color: hintColor),
                                  ],
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
                                              _buildSeatOption(context, '1', false),
                                              _buildSeatOption(context, '2', false),
                                              _buildSeatOption(context, '3', true),
                                              _buildSeatOption(context, '4', false),
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
                                              Text(
                                                '24',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
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
                                  _buildChip(context, Icons.smoke_free, 'No Smoking', false),
                                  _buildChip(context, Icons.pets, 'Pets Allowed', true),
                                  _buildChip(context, Icons.music_note, 'Music', false),
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
                    color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                    border: Border(
                      top: BorderSide(
                        color: borderColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton(
                      onPressed: _isValid
                          ? () {
                              Navigator.pushNamed(context, '/active_ride_dashboard');
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        disabledForegroundColor: Colors.white.withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _isValid ? 4 : 0,
                        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                      child: Row(
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

  Widget _buildSeatOption(BuildContext context, String text, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
                  color: Colors.black.withOpacity(0.05),
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
    );
  }

  Widget _buildChip(
      BuildContext context, IconData icon, String label, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
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
