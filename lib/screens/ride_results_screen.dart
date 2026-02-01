import 'package:co_rider/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class RideResultsScreen extends StatelessWidget {
  const RideResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleButton(
                        context,
                        icon: Icons.arrow_back_ios_new,
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Available Rides',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      Row(
                        children: [
                          _buildCircleButton(
                            context,
                            icon: Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
                             onPressed: () {
                               ThemeController().toggleTheme();
                             },
                          ),
                          const SizedBox(width: 8),
                           Stack(
                            children: [
                              _buildCircleButton(
                                context,
                                icon: Icons.tune,
                                onPressed: () {},
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Search Context Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                      boxShadow: [
                         BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                         )
                      ]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('San Francisco', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey[600])),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_right_alt, color: Colors.grey[400], size: 18),
                        const SizedBox(width: 4),
                        Text('Palo Alto', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey[600])),
                        const SizedBox(width: 8),
                        Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                ),
                // Rides List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildRideCard(
                        context,
                        matchPercentage: 98,
                        price: 12.50,
                        startTime: '17:30',
                        endTime: '18:00',
                        startLocation: 'Downtown (Union Square)',
                        endLocation: 'University Ave, Palo Alto',
                        driverName: 'Sarah M.',
                        driverImage: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCB0np6dlkvVMI-jtDQ3JdOmM84VsxUZQNOYEUl6flGEwxSylwZEbpeye2UkmM2Ffw4JwzalpEFHtcRZ-9XfrDFj8SPPeDxa3NErm2rCUBtq2ipxvjwhKLOz98uupFNOZixrQUUrDQNC9Ly-tZNWEkPOgplawTgTXSLaGFxaH9CFOsUwAJ5Ha-P6ZaWu4NDRbmxKDyn_bCLTadmqaV0K3lKA_xP6YTMEV1QjGp2mDsI5WcyBHDPyQ-_33Gh3mZiNdPQjisgUvweFXlq',
                        carModel: 'Tesla Model 3',
                        seatsLeft: 1,
                        isBestMatch: true,
                        onPressed: () {
                             Navigator.pushNamed(context, '/ride_details');
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildRideCard(
                        context,
                        matchPercentage: 85,
                        price: 10.00,
                        startTime: '17:45',
                        endTime: '18:25',
                        startLocation: 'Market St & 4th',
                        endLocation: 'Stanford Shopping Ctr',
                         driverName: 'David K.',
                         driverImage: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA-XTEofyFVGa6c4We0QDVIogoiB3i-PveQLXt3heEfe5Z05CUS2lJdf8gaRDM_NennuPeLcH0US_RjhVFlNZpPs5QKUr0ODEpYL_d7AK4re8BoEPkYDf3vobf3VrIz_OzeFNITnXUdvSDkgXhKgwt_Zdtvi7IZTLkas7D82twAuOlNyM2MR5i6r4U3yAUSnfE0laE_zY9mMjPe9HtqXfaqQTf8gJ941PqG2UsjxE0E5n10WeO4tdgXgtfnAbK7g6arNYUO_HngzpuE',
                        carModel: 'Toyota Camry',
                        seatsLeft: 3,
                        isEconomy: true,
                        matchColor: Colors.blue,
                        distanceAway: '0.5 mi away',
                        onPressed: () {
                              Navigator.pushNamed(context, '/ride_details');
                        },
                      ),
                       const SizedBox(height: 16),
                      _buildRideCard(
                        context,
                        matchPercentage: 92,
                        price: 14.00,
                        startTime: '18:00',
                        endTime: '18:30',
                        startLocation: 'SOMA District',
                        endLocation: 'Stanford Campus',
                        driverName: 'Emily R.',
                        driverImage: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDfrvvYGk5Gyy07b4AWgLA2mPgnzTw0H3kccZe8ZdkUYB9wVyDIQLo_t3J6C3osSCzg3rOpuJWKDkC6U4w6mTPCafF_MluaboCbTaDKXRY6MpGdU9T3O8wmCMdlUH67gFtEP0Xo7SkFGcdmS7xP7WpMs49mfcfyM4NHkHaUKeJbbOvJBjYYWEecA5f2fOmxEQwc19frmR24ivhBDXgjh4OI__459iLZ14uPnCwVvC0Fgq3UiGYF2Y_oQ2BbfDMi13-F-CfI3eFmvcw2',
                        carModel: 'BMW i3',
                        seatsLeft: 2,
                        matchColor: Colors.grey,
                        distanceAway: '2.0 mi away',
                        onPressed: () {
                              Navigator.pushNamed(context, '/ride_details');
                        },
                      ),
                      const SizedBox(height: 32),
                      const Center(
                        child: Text(
                          'END OF RESULTS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Floating Action Button
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF0F172A),
               foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F172A)
                  : Colors.white,
              child: const Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(BuildContext context,
      {required IconData icon, required VoidCallback onPressed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildRideCard(
    BuildContext context, {
    required int matchPercentage,
    required double price,
    required String startTime,
    required String endTime,
    required String startLocation,
    required String endLocation,
    required String driverName,
    required String driverImage,
    required String carModel,
    required int seatsLeft,
    bool isBestMatch = false,
    bool isEconomy = false,
    Color matchColor = Colors.green,
    String distanceAway = '1.2 mi away',
     required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).cardTheme.color;
    final primaryColor = Theme.of(context).colorScheme.primary;

    Color badgeBgColor;
    Color badgeTextColor;

    if (matchPercentage >= 95) {
       badgeBgColor = isDark ? Colors.green[900]!.withOpacity(0.3) : Colors.green[100]!;
       badgeTextColor = isDark ? Colors.green[400]! : Colors.green[700]!;
    } else if (matchPercentage >= 85) {
       badgeBgColor = isDark ? Colors.blue[900]!.withOpacity(0.3) : Colors.blue[50]!;
       badgeTextColor = isDark ? Colors.blue[300]! : Colors.blue[600]!;
    } else {
       badgeBgColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
       badgeTextColor = isDark ? Colors.grey[300]! : Colors.grey[600]!;
    }


    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      if (matchPercentage >= 95) ...[
                        Icon(Icons.verified, size: 14, color: badgeTextColor),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '$matchPercentage% Match',
                        style: TextStyle(
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$$price${price.truncateToDouble() == price ? "0" : ""}', // basic format
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Timeline
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 // Visual Timeline
                Column(
                  children: [
                     const SizedBox(height: 6),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isBestMatch ? primaryColor : (isDark ? Colors.grey[500]! : Colors.grey[300]!),
                          width: 3,
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 40, // Height between dots
                      color: isDark ? Colors.grey[600]! : Colors.grey[200]!,
                       margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                     Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isBestMatch ? primaryColor : (isDark ? Colors.grey[500]! : Colors.grey[300]!),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      // Start
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                startTime,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                distanceAway,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            startLocation,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // End
                      Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                endTime,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                'Drop-off',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            endLocation,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                             overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: isDark ? Colors.grey[700]! : Colors.grey[100]!),
            const SizedBox(height: 16),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                       children: [
                         Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                             border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[100]!),
                            image: DecorationImage(image: NetworkImage(driverImage), fit: BoxFit.cover),
                          ),
                         ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[700], // Star bg approximation or icon
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(child: Icon(Icons.star, size: 8, color: Colors.white)),
                                ),
                              ),
                            ),
                       ]
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.directions_car, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              carModel,
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            const SizedBox(width: 8),
                            Container(width: 2, height: 10, color: Colors.grey[300]),
                             const SizedBox(width: 8),
                            Icon(Icons.group, size: 14, color: isBestMatch ? primaryColor : Colors.grey[500]), // Highlight if best match
                             const SizedBox(width: 4),
                            Text(
                              '$seatsLeft left',
                              style: TextStyle(fontSize: 12, color: isBestMatch ? primaryColor : Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBestMatch ? primaryColor : (isDark ? Colors.white.withOpacity(0.1) : primaryColor.withOpacity(0.1)),
                    foregroundColor: isBestMatch ? Colors.white : (isDark ? Colors.white : primaryColor),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Book',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
