import 'package:co_rider/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class ActiveRideDashboardScreen extends StatelessWidget {
  const ActiveRideDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[500];
    final borderColor = isDark ? const Color(0xFF1F2937) : Colors.grey[100]!;

    return Scaffold(
      body: Stack(
        children: [
          // Main Scrollable Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleButton(
                        context,
                        icon: Icons.menu,
                        onPressed: () {},
                      ),
                      Text(
                        'Dashboard',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      Row(
                        children: [
                          _buildCircleButton(
                             context,
                             icon: isDark ? Icons.light_mode : Icons.dark_mode, // Simplified toggle
                             onPressed: () {
                               ThemeController().toggleTheme();
                             },
                          ),
                          const SizedBox(width: 8),
                          Stack(
                            children: [
                              _buildCircleButton(
                                context,
                                icon: Icons.notifications,
                                onPressed: () {},
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          _buildCircleButton(
                            context,
                            icon: Icons.shield,
                            color: Theme.of(context).colorScheme.primary,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Scrollable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120), // Bottom padding for fixed bar
                    children: [
                      // Status Chip
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24, top: 8),
                          padding: const EdgeInsets.fromLTRB(16, 8, 20, 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.green[900]!.withOpacity(0.3)
                                : Colors.green[50]!,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isDark ? Colors.green[800]! : Colors.green[200]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ACTIVE RIDE',
                                style: TextStyle(
                                  color: isDark ? Colors.green[300] : Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Main Ride Card
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
                              blurRadius: 30,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Map Preview
                            SizedBox(
                              height: 160,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.vertical(top: Radius.circular(16)),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBvjgYTzHdX-m4g8Bd-XMMZkMoiQ1TC-nlTwfXBZh4zdyTT174A4cZpe4GQUiCBAzFZC26i-kjdCAB9zKW7L5z2sCQGSG06ruVXUCs4gJsvUo18RZVmjKh23RkscAL-IpJdyPOYZVB4esWXqK06_dQnMgNYMxrqFrlvhhnG0W46AwdzrkH0aIJxX0knZjpwAktKJYOUSvTpRv68FF0L3FZ-9ha8XvWwOUhaIKKTzk1tkLQdQGjucK6WBrw5_9fDChpNjkEsF8o_XzlI'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.1),
                                          Colors.transparent,
                                          surfaceColor!,
                                        ],
                                      ),
                                    ),
                                  ),
                                  // ETA Badge
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: surfaceColor.withOpacity(isDark ? 0.9 : 1.0),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: isDark
                                                ? Colors.grey[700]!
                                                : Colors.grey[100]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.schedule,
                                              size: 18,
                                              color: Theme.of(context).colorScheme.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            '15 min',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
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
                            // Card Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  // Trip Header
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'CURRENT TRIP',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '10:45 AM',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              color: textColor,
                                              height: 1.1,
                                            ),
                                          ),
                                          Text(
                                            'Estimated Arrival',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.blue[900]!.withOpacity(0.2)
                                                  : Colors.blue[50],
                                              borderRadius: BorderRadius.circular(999),
                                              border: Border.all(
                                                color: isDark
                                                    ? Colors.blue[800]!.withOpacity(0.5)
                                                    : Colors.blue[100]!,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.airline_seat_recline_normal,
                                                  size: 16,
                                                  color:
                                                      Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '2/4',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Seats Filled',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[400],
                                              // dark:text-gray-500
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Divider(height: 1, color: borderColor),
                                  const SizedBox(height: 24),
                                  // Timeline Route
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Visual Line
                                          Column(
                                            children: [
                                              const SizedBox(height: 6),
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? const Color(0xFF1F2937)
                                                      : Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isDark
                                                        ? Colors.grey[600]!
                                                        : Colors.grey[300]!,
                                                    width: 3,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 2,
                                                height: 40,
                                                color: Colors.grey[300], // approximated
                                                margin: const EdgeInsets.symmetric(
                                                    vertical: 4),
                                              ),
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withOpacity(0.3),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Source
                                                Opacity(
                                                  opacity: 0.6,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '124 Market St',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                      Text(
                                                        'San Francisco • Picked up',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: secondaryTextColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                // Destination
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '4005 3rd St',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Palo Alto • Drop off',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  // Passenger Avatars
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.grey[800]!.withOpacity(0.5)
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.grey[800]!.withOpacity(0.5)
                                            : Colors.grey[100]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Avatars (Placeholder Circles)
                                         SizedBox(
                                          width: 58,
                                          height: 32,
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: surfaceColor!, width: 2),
                                                  image: const DecorationImage(image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAdhi4RA8Q77QHi_LPHcNSB8bs2D_jLsFSuG_dZjmb-DuJRRubo14OXJfvJziiU7ZRaKqrz9P4SBvaI3dT4Nh2n3DPmA5BNr6Rbb81dV6w7wmoQJ54b2QYWaKwhr5BXK-CCk4j04e50YLA0ovRLObv2JpTPN-zRUN17Pz8T4PuHLFaP88mp5Q0tEKZ8TGtGiueut-bjGfzHYOIl4MkI7fj69mWRxidJJYu1s3ntZD4fPPNFsciG8u1c_k57KLRGxXEAvW_qozztnDWX"), fit: BoxFit.cover), 
                                                ),
                                              ),
                                              Positioned(
                                                left: 24,
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: surfaceColor, width: 2),
                                                    image: const DecorationImage(image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuCInLdkO-zCizLIopwb0NuHCV_w0QtoUGXQoFEhcWcJ3q4bIgYiBsMlk_-Ta-zbl8xLUqfsx12bgD9seDefVpFe9WmaE7NB4uV-DwmxLa-peKroVPkpsH8ZIicfHMO0mP1DtR2_VOO50gFxuxbEX21xjJs6oFpSNYueua2i2WzEagofHsLYsXeBhpz_EfL9Gbz_8-Mqtk9Hpd4QlPNK7RA0ypV-z_NSFu6vNuOMHSQQpBgc9t_BsTdcUI7paNcTr1fLkUrgMJ9OJfBD"), fit: BoxFit.cover),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sarah & Mike',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              'Passengers on board',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Icon(Icons.more_horiz,
                                            color: Colors.grey[400]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              isDark,
                              surfaceColor!,
                              borderColor,
                              isDark ? Colors.white : Colors.black,
                              icon: Icons.payments,
                              badgeText: '+15%',
                              badgeColor: Colors.green,
                              value: '\$42.50',
                              label: 'Earned so far',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              isDark,
                              surfaceColor,
                              borderColor,
                              isDark ? Colors.white : Colors.black,
                              icon: Icons.speed,
                              value: '28 mi',
                              label: 'Total distance',
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                      Theme.of(context).scaffoldBackgroundColor,
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      _buildSquareButton(
                        context,
                        icon: Icons.call,
                        isPrimary: false,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                             Navigator.pushNamed(context, '/search_rides');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            fixedSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor:
                                Theme.of(context).colorScheme.primary.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.navigation),
                              SizedBox(width: 8),
                              Text(
                                'Navigate',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildSquareButton(
                        context,
                        icon: Icons.menu_open,
                        isPrimary: false,
                      ),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildCircleButton(BuildContext context,
      {required IconData icon,
      Color? color,
      Color? backgroundColor,
      required VoidCallback onPressed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isDark ? Colors.transparent : Colors.grey[100]), // hover effect not statically visible
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 24,
          color: color ?? (isDark ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor, {
    required IconData icon,
    String? badgeText,
    Color? badgeColor,
    required String value,
    required String label,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.grey[400], size: 24),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF4ADE80) : Colors.green[600],
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSquareButton(BuildContext context,
      {required IconData icon, required bool isPrimary}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}
