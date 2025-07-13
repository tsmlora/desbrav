import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/expanded_stats_panel_widget.dart';
import './widgets/map_widget.dart';
import './widgets/tracking_controls_widget.dart';
import './widgets/tracking_stats_overlay_widget.dart';

class GpsTrackingScreen extends StatefulWidget {
  const GpsTrackingScreen({super.key});

  @override
  State<GpsTrackingScreen> createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends State<GpsTrackingScreen>
    with TickerProviderStateMixin {
  // Tracking state
  bool _isTracking = false;
  bool _isPaused = false;
  bool _isExpanded = false;

  // Statistics
  double _currentSpeed = 0.0;
  double _distance = 0.0;
  Duration _rideDuration = Duration.zero;
  double _averageSpeed = 0.0;
  double _elevationGain = 0.0;
  int _caloriesBurned = 0;
  double _fuelConsumption = 0.0;

  // Location data
  double _currentLatitude = -23.5505;
  double _currentLongitude = -46.6333;
  double _heading = 0.0;

  // Timers
  Timer? _trackingTimer;
  Timer? _speedUpdateTimer;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock route points for demonstration
  final List<Map<String, dynamic>> _routePoints = [
    {"lat": -23.5505, "lng": -46.6333, "timestamp": DateTime.now()},
    {
      "lat": -23.5515,
      "lng": -46.6343,
      "timestamp": DateTime.now().add(Duration(minutes: 1)),
    },
    {
      "lat": -23.5525,
      "lng": -46.6353,
      "timestamp": DateTime.now().add(Duration(minutes: 2)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLocationUpdates();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _startLocationUpdates() {
    _speedUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isTracking && !_isPaused) {
        setState(() {
          // Simulate GPS updates
          _currentSpeed = 45.0 + (Random().nextDouble() * 20.0);
          _distance += _currentSpeed / 3600; // Convert km/h to km per second
          _rideDuration = _rideDuration + Duration(seconds: 1);
          _averageSpeed = _distance / (_rideDuration.inSeconds / 3600);
          _elevationGain += Random().nextDouble() * 0.5;
          _caloriesBurned = (_rideDuration.inMinutes * 8).round();
          _fuelConsumption = _distance * 0.05; // 5L/100km estimate

          // Update position slightly
          _currentLatitude += (Random().nextDouble() - 0.5) * 0.0001;
          _currentLongitude += (Random().nextDouble() - 0.5) * 0.0001;
          _heading = (Random().nextDouble() * 360);
        });
      }
    });
  }

  void _toggleTracking() {
    setState(() {
      if (_isTracking) {
        _stopTracking();
      } else {
        _startTracking();
      }
    });
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
      _isPaused = false;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _isPaused = false;
      // Reset statistics
      _currentSpeed = 0.0;
      _distance = 0.0;
      _rideDuration = Duration.zero;
      _averageSpeed = 0.0;
      _elevationGain = 0.0;
      _caloriesBurned = 0;
      _fuelConsumption = 0.0;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _pauseResumeTracking() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _addWaypoint() {
    // Add current location as waypoint
    _routePoints.add({
      "lat": _currentLatitude,
      "lng": _currentLongitude,
      "timestamp": DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Waypoint adicionado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _emergencyContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contato de Emergência'),
        content: Text(
          'Deseja ligar para o contato de emergência e compartilhar sua localização?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate emergency call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ligando para emergência...'),
                  backgroundColor: AppTheme.errorLight,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text('Ligar'),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 50.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações de GPS',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'gps_fixed',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: Text('Precisão do GPS'),
              subtitle: Text('Alta precisão'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'battery_saver',
                color: AppTheme.successLight,
                size: 24,
              ),
              title: Text('Modo Economia'),
              subtitle: Text('Reduz uso da bateria'),
              trailing: Switch(value: false, onChanged: (value) {}),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'volume_up',
                color: AppTheme.secondaryLight,
                size: 24,
              ),
              title: Text('Anúncios de Voz'),
              subtitle: Text('Marcos e conquistas'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleExpandedStats() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  Color _getSpeedColor() {
    if (_currentSpeed <= 50) return AppTheme.successLight;
    if (_currentSpeed <= 80) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _speedUpdateTimer?.cancel();
    _pulseController.dispose();
    _slideController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen map
            MapWidget(
              currentLatitude: _currentLatitude,
              currentLongitude: _currentLongitude,
              heading: _heading,
              routePoints: _routePoints,
              isTracking: _isTracking,
            ),

            // Top statistics overlay
            Positioned(
              top: 2.h,
              left: 4.w,
              right: 4.w,
              child: TrackingStatsOverlayWidget(
                currentSpeed: _currentSpeed,
                distance: _distance,
                rideDuration: _rideDuration,
                averageSpeed: _averageSpeed,
                speedColor: _getSpeedColor(),
                isTracking: _isTracking,
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 2.h,
              left: 4.w,
              right: 4.w,
              child: TrackingControlsWidget(
                isTracking: _isTracking,
                isPaused: _isPaused,
                onToggleTracking: _toggleTracking,
                onPauseResume: _pauseResumeTracking,
                onAddWaypoint: _addWaypoint,
                onEmergencyContact: _emergencyContact,
                onOpenSettings: _openSettings,
                pulseAnimation: _pulseAnimation,
              ),
            ),

            // Expanded statistics panel
            if (_isExpanded)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ExpandedStatsPanelWidget(
                    elevationGain: _elevationGain,
                    caloriesBurned: _caloriesBurned,
                    fuelConsumption: _fuelConsumption,
                    onClose: _toggleExpandedStats,
                  ),
                ),
              ),

            // Swipe up gesture detector for expanded stats
            Positioned(
              bottom: 15.h,
              left: 0,
              right: 0,
              height: 5.h,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy < -5 && !_isExpanded) {
                    _toggleExpandedStats();
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Container(
                      width: 10.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 2.h,
              left: 4.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
