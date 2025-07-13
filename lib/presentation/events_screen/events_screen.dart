import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calendar_widget.dart';
import './widgets/event_card_widget.dart';
import './widgets/event_filter_bottom_sheet.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isCalendarView = true;
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Mock data for events
  final List<Map<String, dynamic>> _events = [
    {
      "id": 1,
      "title": "Trilha da Serra do Mar",
      "description": "Aventura épica pelas montanhas com paisagens incríveis",
      "date": DateTime(2025, 7, 15),
      "time": "08:00",
      "location": "Parque Nacional da Serra do Mar, SP",
      "distance": "45 km",
      "participantCount": 23,
      "maxParticipants": 30,
      "eventType": "group_ride",
      "coverImage":
          "https://images.pexels.com/photos/163210/motorcycles-race-helmets-pilots-163210.jpeg",
      "rsvpStatus":
          "going", // going, interested, not_going, none "organizerName": "Carlos Silva",
      "organizerAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "price": "Gratuito",
      "difficulty": "Intermediário",
    },
    {
      "id": 2,
      "title": "Encontro Motociclístico SP",
      "description": "Grande encontro de motociclistas com exposição e shows",
      "date": DateTime(2025, 7, 18),
      "time": "14:00",
      "location": "Expo Center Norte, São Paulo",
      "distance": "12 km",
      "participantCount": 156,
      "maxParticipants": 200,
      "eventType": "meetup",
      "coverImage":
          "https://images.pexels.com/photos/2116475/pexels-photo-2116475.jpeg",
      "rsvpStatus": "interested",
      "organizerName": "Moto Clube SP",
      "organizerAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "price": "R\$ 25,00",
      "difficulty": "Todos os níveis",
    },
    {
      "id": 3,
      "title": "Rally Sertão Nordestino",
      "description": "3 dias de aventura pelo sertão com acampamento",
      "date": DateTime(2025, 7, 22),
      "time": "06:00",
      "location": "Caruaru, PE",
      "distance": "850 km",
      "participantCount": 67,
      "maxParticipants": 80,
      "eventType": "rally",
      "coverImage":
          "https://images.pexels.com/photos/1119796/pexels-photo-1119796.jpeg",
      "rsvpStatus": "none",
      "organizerName": "Adventure Nordeste",
      "organizerAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "price": "R\$ 180,00",
      "difficulty": "Avançado",
    },
    {
      "id": 4,
      "title": "Workshop Manutenção Básica",
      "description": "Aprenda manutenção básica da sua moto com especialistas",
      "date": DateTime(2025, 7, 20),
      "time": "09:00",
      "location": "Oficina Central, Rio de Janeiro",
      "distance": "8 km",
      "participantCount": 12,
      "maxParticipants": 15,
      "eventType": "workshop",
      "coverImage":
          "https://images.pexels.com/photos/190574/pexels-photo-190574.jpeg",
      "rsvpStatus": "going",
      "organizerName": "Mecânica Expert",
      "organizerAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "price": "R\$ 50,00",
      "difficulty": "Iniciante",
    },
    {
      "id": 5,
      "title": "Passeio Litoral Paulista",
      "description": "Rota cênica pela costa com paradas gastronômicas",
      "date": DateTime(2025, 7, 25),
      "time": "07:30",
      "location": "Santos, SP",
      "distance": "120 km",
      "participantCount": 34,
      "maxParticipants": 40,
      "eventType": "group_ride",
      "coverImage":
          "https://images.pexels.com/photos/1119796/pexels-photo-1119796.jpeg",
      "rsvpStatus": "interested",
      "organizerName": "Litoral Riders",
      "organizerAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "price": "R\$ 35,00",
      "difficulty": "Intermediário",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_searchQuery.isEmpty) return _events;
    return _events.where((event) {
      final title = (event['title'] as String).toLowerCase();
      final location = (event['location'] as String).toLowerCase();
      final description = (event['description'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) ||
          location.contains(query) ||
          description.contains(query);
    }).toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventFilterBottomSheet(
        onApplyFilters: (filters) {
          // Apply filters logic here
          Navigator.pop(context);
        },
      ),
    );
  }

  void _createEvent() {
    // Navigate to event creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcionalidade de criar evento em desenvolvimento'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  Future<void> _refreshEvents() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      // Refresh events data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        title: Text(
          'Eventos',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(12.h),
          child: Column(
            children: [
              // Search bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.dividerColor,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar eventos...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                  ),
                ),
              ),
              // Tab bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  onTap: (index) {
                    setState(() {
                      _isCalendarView = index == 0;
                    });
                  },
                  indicator: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'calendar_today',
                            color: _isCalendarView
                                ? Colors.white
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Text('Calendário'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'list',
                            color: !_isCalendarView
                                ? Colors.white
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Text('Lista'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEvents,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Calendar View
            CalendarWidget(
              events: _filteredEvents,
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            // List View
            _buildEventsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createEvent,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: CustomIconWidget(iconName: 'add', color: Colors.white, size: 24),
        label: Text(
          'Criar Evento',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    if (_filteredEvents.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return EventCardWidget(
          event: event,
          onTap: () => _navigateToEventDetails(event),
          onRSVPChanged: (status) => _updateRSVPStatus(event['id'], status),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'event_available',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 80,
          ),
          SizedBox(height: 3.h),
          Text(
            'Nenhum evento encontrado',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Organize seu primeiro passeio ou\najuste os filtros de busca',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _createEvent,
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 20,
            ),
            label: Text('Criar Primeiro Evento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEventDetails(Map<String, dynamic> event) {
    // Navigate to event details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo detalhes do evento: ${event['title']}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _updateRSVPStatus(int eventId, String status) {
    setState(() {
      final eventIndex = _events.indexWhere((event) => event['id'] == eventId);
      if (eventIndex != -1) {
        _events[eventIndex]['rsvpStatus'] = status;

        // Update participant count based on RSVP
        if (status == 'going') {
          _events[eventIndex]['participantCount']++;
        } else if (_events[eventIndex]['rsvpStatus'] == 'going' &&
            status != 'going') {
          _events[eventIndex]['participantCount']--;
        }
      }
    });

    // Show feedback
    String message = '';
    switch (status) {
      case 'going':
        message = 'Confirmado! Você vai participar do evento';
        break;
      case 'interested':
        message = 'Marcado como interessado';
        break;
      case 'not_going':
        message = 'Você não vai participar do evento';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
