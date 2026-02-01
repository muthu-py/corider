import 'dart:ui';

import 'package:co_rider/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ...
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).scaffoldBackgroundColor;
    final sheetColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    // final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[500];

    return Scaffold(
      body: Stack(
        children: [
          // Map Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBvjgYTzHdX-m4g8Bd-XMMZkMoiQ1TC-nlTwfXBZh4zdyTT174A4cZpe4GQUiCBAzFZC26i-kjdCAB9zKW7L5z2sCQGSG06ruVXUCs4gJsvUo18RZVmjKh23RkscAL-IpJdyPOYZVB4esWXqK06_dQnMgNYMxrqFrlvhhnG0W46AwdzrkH0aIJxX0knZjpwAktKJYOUSvTpRv68FF0L3FZ-9ha8XvWwOUhaIKKTzk1tkLQdQGjucK6WBrw5_9fDChpNjkEsF8o_XzlI'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Top App Bar (Overlaid)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBlurButton(
                      context,
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                    ),
                    ClipRRect(
                       borderRadius: BorderRadius.circular(999),
                       child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.9),
                            child: Text(
                              'Ride Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                       ),
                    ),
                    _buildBlurButton(
                      context,
                      icon: isDark ? Icons.light_mode : Icons.dark_mode,
                      onPressed: () {
                         ThemeController().toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Details Sheet
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45 - 30, // Overlap
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                      children: [
                        // Price & Time Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Fare',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$24.50',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    'Standard',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Text(
                                  '08:30 AM',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  '2h 15m duration',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(height: 1, color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                        const SizedBox(height: 24),
                        // Timeline Route
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const SizedBox(height: 4),
                                Container(
                                  width: 16,
                                  height: 16,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 50,
                                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                                ),
                                Icon(Icons.location_on, size: 24, color: Theme.of(context).colorScheme.primary),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'San Francisco Intl. Airport',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        'Terminal 2, Arrivals',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 36),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Palo Alto Tech Park',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        '3300 Hillview Ave',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(height: 1, color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                        const SizedBox(height: 24),
                        // Driver Info
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey[200]!, width: 2),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDV-tyvL5hru_rCeZJDnkp8f-mUBwEyUprJu6_Q47sUC1nyWgBGqo3Q0wbFcbiuIGzD8Vp36YzxunoI7tMStF_T49_5d_pCN69t4083hoXucp9VyleoMMOn1ONnhGFyte2lwHp8F07Ds4gHadn34pjm0nhNT1G2XZj1Eo7-ZO9o2Q_WNo7ulTk2Q1K_orgQogwYxndUCKUCq2I8CLhL8EU8EFcAou1XHSoG2fBN1p_JjC-EbB9Lu0sfgnDQfJ7jl9EfXYtWFhwVsYeD'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Michael D.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 16, color: Colors.orange),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.9',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('•', style: TextStyle(color: Colors.grey[500])),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Toyota Camry',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _buildActionButton(context, Icons.chat_bubble),
                                const SizedBox(width: 8),
                                _buildActionButton(context, Icons.call),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Amenities
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildChip(context, Icons.ac_unit, 'AC'),
                              const SizedBox(width: 8),
                              _buildChip(context, Icons.volume_off, 'Quiet Ride'),
                              const SizedBox(width: 8),
                              _buildChip(context, Icons.masks, 'Mask Required'),
                              const SizedBox(width: 8),
                              _buildChip(context, Icons.airline_seat_recline_extra, '4 Seats'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Fixed Bottom Action Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                 child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF101622).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                    border: Border(top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[100]!)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton(
                      onPressed: () {
                         // Action
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Request Sent!')),
                         );
                         Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Request Ride',
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


  Widget _buildBlurButton(BuildContext context, {required IconData icon, required VoidCallback onPressed}) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     return GestureDetector(
       onTap: onPressed,
       child: ClipRRect(
         borderRadius: BorderRadius.circular(999),
         child: Container( // BackdropFilter needs a parent with clip usually if we want rounded.
           // Actually simpler: Container with color opacity.
           width: 40,
           height: 40,
           decoration: BoxDecoration(
             color: isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.9),
             shape: BoxShape.circle,
             boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
             ]
           ),
           child: Icon(
             icon,
             size: 24,
             color: isDark ? Colors.white : Colors.black,
           ),
         ),
       ),
     );
  }

   Widget _buildActionButton(BuildContext context, IconData icon) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     return Container(
       width: 40,
       height: 40,
       decoration: BoxDecoration(
         color: isDark ? Colors.grey[800] : Colors.grey[100],
         shape: BoxShape.circle,
       ),
       child: Icon(
         icon,
         size: 20,
         color: Colors.grey[600],
       ),
    );
   }

   Widget _buildChip(BuildContext context, IconData icon, String label) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
       decoration: BoxDecoration(
         color: isDark ? Colors.grey[800] : Colors.white,
         borderRadius: BorderRadius.circular(8),
         border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
       ),
       child: Row(
         children: [
           Icon(icon, size: 16, color: Colors.grey[600]),
           const SizedBox(width: 6),
           Text(
             label,
             style: TextStyle(
               fontSize: 12,
               fontWeight: FontWeight.w500,
               color: Colors.grey[600],
             ),
           ),
         ],
       ),
     );
   }
}
