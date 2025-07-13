import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapWidget extends StatefulWidget {
  final double currentLatitude;
  final double currentLongitude;
  final double heading;
  final List<Map<String, dynamic>> routePoints;
  final bool isTracking;

  const MapWidget({
    super.key,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.heading,
    required this.routePoints,
    required this.isTracking,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  double _zoomLevel = 15.0;
  double _mapRotation = 0.0;
  Offset _mapCenter = Offset.zero;
  bool _followLocation = true;

  @override
  void initState() {
    super.initState();
    _mapCenter = Offset(widget.currentLongitude, widget.currentLatitude);
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_followLocation) {
      _mapCenter = Offset(widget.currentLongitude, widget.currentLatitude);
    }
  }

  void _handleMapTap(TapDownDetails details) {
    setState(() {
      _followLocation = false;
    });
  }

  void _centerOnLocation() {
    setState(() {
      _mapCenter = Offset(widget.currentLongitude, widget.currentLatitude);
      _followLocation = true;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _zoomLevel = (_zoomLevel * details.scale).clamp(5.0, 20.0);
      _mapRotation += details.rotation;
      _followLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFF1A1A1A),
      child: Stack(
        children: [
          // Map background with grid pattern
          GestureDetector(
            onTapDown: _handleMapTap,
            onScaleUpdate: _handleScaleUpdate,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: MapPainter(
                  center: _mapCenter,
                  zoomLevel: _zoomLevel,
                  rotation: _mapRotation,
                  currentPosition: Offset(
                    widget.currentLongitude,
                    widget.currentLatitude,
                  ),
                  heading: widget.heading,
                  routePoints: widget.routePoints,
                  isTracking: widget.isTracking,
                ),
              ),
            ),
          ),

          // Center on location button
          Positioned(
            right: 4.w,
            bottom: 25.h,
            child: Container(
              decoration: BoxDecoration(
                color: _followLocation
                    ? AppTheme.primaryLight
                    : Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: _centerOnLocation,
                icon: CustomIconWidget(
                  iconName: 'my_location',
                  color: _followLocation
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.8),
                  size: 24,
                ),
              ),
            ),
          ),

          // Zoom controls
          Positioned(
            right: 4.w,
            top: 20.h,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel + 1).clamp(5.0, 20.0);
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: 'add',
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel - 1).clamp(5.0, 20.0);
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: 'remove',
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Compass
          Positioned(
            left: 4.w,
            bottom: 25.h,
            child: Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Transform.rotate(
                angle: widget.heading * pi / 180,
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'navigation',
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final Offset center;
  final double zoomLevel;
  final double rotation;
  final Offset currentPosition;
  final double heading;
  final List<Map<String, dynamic>> routePoints;
  final bool isTracking;

  MapPainter({
    required this.center,
    required this.zoomLevel,
    required this.rotation,
    required this.currentPosition,
    required this.heading,
    required this.routePoints,
    required this.isTracking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw map background
    paint.color = Color(0xFF2D2D2D);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw grid pattern to simulate map tiles
    paint.color = Color(0xFF404040);
    paint.strokeWidth = 1;

    final gridSize = 50.0 * (zoomLevel / 15.0);
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw route trail if tracking
    if (isTracking && routePoints.length > 1) {
      paint.color = Color(0xFFFF6B35);
      paint.strokeWidth = 4;
      paint.style = PaintingStyle.stroke;

      final path = Path();
      for (int i = 0; i < routePoints.length; i++) {
        final point = _latLngToScreen(
          routePoints[i]["lat"],
          routePoints[i]["lng"],
          size,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, paint);

      // Draw waypoint markers
      paint.style = PaintingStyle.fill;
      paint.color = Color(0xFFFF6B35);
      for (final point in routePoints) {
        final screenPoint = _latLngToScreen(point["lat"], point["lng"], size);
        canvas.drawCircle(screenPoint, 6, paint);

        paint.color = Colors.white;
        canvas.drawCircle(screenPoint, 3, paint);
        paint.color = Color(0xFFFF6B35);
      }
    }

    // Draw current position marker (motorcycle)
    final currentScreenPos = _latLngToScreen(
      currentPosition.dy,
      currentPosition.dx,
      size,
    );

    // Motorcycle marker background
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(currentScreenPos, 20, paint);

    // Motorcycle marker
    paint.color = Color(0xFFFF6B35);
    canvas.drawCircle(currentScreenPos, 16, paint);

    // Direction indicator
    canvas.save();
    canvas.translate(currentScreenPos.dx, currentScreenPos.dy);
    canvas.rotate(heading * pi / 180);

    paint.color = Colors.white;
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -12), Offset(0, 0), paint);

    // Arrow head
    paint.style = PaintingStyle.fill;
    final arrowPath = Path();
    arrowPath.moveTo(0, -12);
    arrowPath.lineTo(-4, -8);
    arrowPath.lineTo(4, -8);
    arrowPath.close();
    canvas.drawPath(arrowPath, paint);

    canvas.restore();

    // Draw scale indicator
    _drawScaleIndicator(canvas, size);
  }

  Offset _latLngToScreen(double lat, double lng, Size size) {
    // Simple projection for demonstration
    final centerLat = center.dy;
    final centerLng = center.dx;

    final scale = zoomLevel * 1000;
    final x = size.width / 2 + (lng - centerLng) * scale;
    final y = size.height / 2 - (lat - centerLat) * scale;

    return Offset(x, y);
  }

  void _drawScaleIndicator(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    final scaleLength = 100.0;
    final scaleStart = Offset(20, size.height - 40);
    final scaleEnd = Offset(scaleStart.dx + scaleLength, scaleStart.dy);

    // Scale line
    canvas.drawLine(scaleStart, scaleEnd, paint);
    canvas.drawLine(
      Offset(scaleStart.dx, scaleStart.dy - 5),
      Offset(scaleStart.dx, scaleStart.dy + 5),
      paint,
    );
    canvas.drawLine(
      Offset(scaleEnd.dx, scaleEnd.dy - 5),
      Offset(scaleEnd.dx, scaleEnd.dy + 5),
      paint,
    );

    // Scale text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(scaleLength / zoomLevel * 15 / 1000).toStringAsFixed(1)} km',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(scaleStart.dx, scaleStart.dy - 25));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
