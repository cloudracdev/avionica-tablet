import 'package:flutter/material.dart';
import '../painters/bussola_painter.dart';

/// Compass/Heading indicator widget.
///
/// Displays magnetic heading with rotating compass rose and fixed airplane symbol.
/// Includes smooth heading transitions to avoid sudden jumps at 0/360° boundary.
class BussolaWidget extends StatefulWidget {
  /// Magnetic heading in degrees (0-360)
  final double heading;

  const BussolaWidget({
    super.key,
    required this.heading,
  });

  @override
  State<BussolaWidget> createState() => _BussolaWidgetState();
}

class _BussolaWidgetState extends State<BussolaWidget> {
  double _displayHeading = 0;

  @override
  void initState() {
    super.initState();
    _displayHeading = _normalizeHeading(widget.heading);
  }

  @override
  void didUpdateWidget(BussolaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Calculate shortest angular distance for smooth transition
    double newHeading = _normalizeHeading(widget.heading);
    double diff = newHeading - _displayHeading;

    // Adjust to take shortest path (avoid 359° → 0° jump)
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    _displayHeading = _normalizeHeading(_displayHeading + diff);
  }

  /// Normalizes heading to 0-360° range.
  double _normalizeHeading(double heading) {
    while (heading < 0) {
      heading += 360;
    }
    while (heading >= 360) {
      heading -= 360;
    }
    return heading;
  }

  /// Gets cardinal direction label (N, NE, E, SE, S, SO, O, NO).
  String _getCardinalDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE';
    if (degrees >= 67.5 && degrees < 112.5) return 'E';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'SO';
    if (degrees >= 247.5 && degrees < 292.5) return 'O';
    return 'NO';
  }

  @override
  Widget build(BuildContext context) {
    String cardinal = _getCardinalDirection(_displayHeading);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.purple, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'BÚSSOLA',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Instrument (uses separate Painter)
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CustomPaint(
                    painter: BussolaPainter(heading: _displayHeading),
                  ),
                ),
              ),
            ),
          ),

          // Numeric values with cardinal direction
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${_displayHeading.toInt()}° ($cardinal)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}