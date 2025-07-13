import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/month_year_picker_widget.dart';
import './widgets/route_card_widget.dart';
import './widgets/statistics_summary_widget.dart';

class RouteHistoryScreen extends StatefulWidget {
  const RouteHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RouteHistoryScreen> createState() => _RouteHistoryScreenState();
}

class _RouteHistoryScreenState extends State<RouteHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isMultiSelectMode = false;
  Set<int> _selectedRoutes = {};
  String _selectedMonth = 'Julho';
  String _selectedYear = '2025';
  String _searchQuery = '';

  // Mock data for route history
  final List<Map<String, dynamic>> _routeHistory = [
    {
      "id": 1,
      "title": "Serra da Mantiqueira",
      "date": "12/07/2025",
      "distance": "245.8 km",
      "duration": "4h 32min",
      "thumbnailUrl":
          "https://images.pexels.com/photos/1118873/pexels-photo-1118873.jpeg?auto=compress&cs=tinysrgb&w=400",
      "startLocation": "São Paulo, SP",
      "endLocation": "Campos do Jordão, SP",
      "achievements": ["Explorador", "Montanhista"],
      "elevationGain": "1,245m",
      "avgSpeed": "54 km/h",
      "maxSpeed": "89 km/h",
      "notes": "Trilha incrível pelas montanhas",
      "photos": 12,
      "isSynced": true,
    },
    {
      "id": 2,
      "title": "Litoral Norte",
      "date": "10/07/2025",
      "distance": "189.3 km",
      "duration": "3h 15min",
      "thumbnailUrl":
          "https://images.pexels.com/photos/1051075/pexels-photo-1051075.jpeg?auto=compress&cs=tinysrgb&w=400",
      "startLocation": "Santos, SP",
      "endLocation": "Ubatuba, SP",
      "achievements": ["Costeiro", "Velocista"],
      "elevationGain": "456m",
      "avgSpeed": "58 km/h",
      "maxSpeed": "95 km/h",
      "notes": "Estrada costeira com vista para o mar",
      "photos": 8,
      "isSynced": true,
    },
    {
      "id": 3,
      "title": "Vale do Paraíba",
      "date": "08/07/2025",
      "distance": "156.7 km",
      "duration": "2h 48min",
      "thumbnailUrl":
          "https://images.pixabay.com/photo-2016/11/29/05/45/astronomy-1867616_640.jpg",
      "startLocation": "Taubaté, SP",
      "endLocation": "Aparecida, SP",
      "achievements": ["Peregrino"],
      "elevationGain": "234m",
      "avgSpeed": "56 km/h",
      "maxSpeed": "78 km/h",
      "notes": "Viagem espiritual",
      "photos": 5,
      "isSynced": false,
    },
    {
      "id": 4,
      "title": "Circuito das Águas",
      "date": "05/07/2025",
      "distance": "312.4 km",
      "duration": "5h 22min",
      "thumbnailUrl":
          "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=400&q=60",
      "startLocation": "Poços de Caldas, MG",
      "endLocation": "São Lourenço, MG",
      "achievements": ["Aventureiro", "Resistência"],
      "elevationGain": "1,567m",
      "avgSpeed": "58 km/h",
      "maxSpeed": "102 km/h",
      "notes": "Tour pelas cidades termais",
      "photos": 18,
      "isSynced": true,
    },
    {
      "id": 5,
      "title": "Estrada Real",
      "date": "02/07/2025",
      "distance": "278.9 km",
      "duration": "4h 56min",
      "thumbnailUrl":
          "https://images.pexels.com/photos/1402787/pexels-photo-1402787.jpeg?auto=compress&cs=tinysrgb&w=400",
      "startLocation": "Ouro Preto, MG",
      "endLocation": "Tiradentes, MG",
      "achievements": ["Histórico", "Explorador"],
      "elevationGain": "892m",
      "avgSpeed": "56 km/h",
      "maxSpeed": "87 km/h",
      "notes": "Rota histórica colonial",
      "photos": 15,
      "isSynced": true,
    },
  ];

  List<Map<String, dynamic>> get _filteredRoutes {
    if (_searchQuery.isEmpty) return _routeHistory;
    return _routeHistory.where((route) {
      final title = (route['title'] as String).toLowerCase();
      final startLocation = (route['startLocation'] as String).toLowerCase();
      final endLocation = (route['endLocation'] as String).toLowerCase();
      final notes = (route['notes'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();

      return title.contains(query) ||
          startLocation.contains(query) ||
          endLocation.contains(query) ||
          notes.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreRoutes();
    }
  }

  Future<void> _loadMoreRoutes() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
  }

  Future<void> _refreshRoutes() async {
    setState(() => _isLoading = true);

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        onApplyFilters: (filters) {
          // Apply filters logic here
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MonthYearPickerWidget(
        selectedMonth: _selectedMonth,
        selectedYear: _selectedYear,
        onDateSelected: (month, year) {
          setState(() {
            _selectedMonth = month;
            _selectedYear = year;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedRoutes.clear();
      }
    });
  }

  void _toggleRouteSelection(int routeId) {
    setState(() {
      if (_selectedRoutes.contains(routeId)) {
        _selectedRoutes.remove(routeId);
      } else {
        _selectedRoutes.add(routeId);
      }
    });
  }

  void _exportSelectedRoutes() {
    // Export logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedRoutes.length} rotas exportadas com sucesso!',
        ),
        backgroundColor: AppTheme.successLight,
      ),
    );
    _toggleMultiSelectMode();
  }

  void _deleteSelectedRoutes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Rotas'),
        content: Text(
          'Deseja excluir ${_selectedRoutes.length} rota(s) selecionada(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Delete logic here
              Navigator.pop(context);
              _toggleMultiSelectMode();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rotas excluídas com sucesso!'),
                ),
              );
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: AppTheme.errorLight),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        title: _isMultiSelectMode
            ? Text('${_selectedRoutes.length} selecionada(s)')
            : const Text('Histórico de Rotas'),
        leading: _isMultiSelectMode
            ? IconButton(
                onPressed: _toggleMultiSelectMode,
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              )
            : null,
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              onPressed:
                  _selectedRoutes.isNotEmpty ? _exportSelectedRoutes : null,
              icon: CustomIconWidget(
                iconName: 'share',
                color: _selectedRoutes.isNotEmpty
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                size: 24,
              ),
            ),
            IconButton(
              onPressed:
                  _selectedRoutes.isNotEmpty ? _deleteSelectedRoutes : null,
              icon: CustomIconWidget(
                iconName: 'delete',
                color: _selectedRoutes.isNotEmpty
                    ? AppTheme.errorLight
                    : AppTheme.lightTheme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                size: 24,
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: _showMonthYearPicker,
              child: Container(
                margin: EdgeInsets.only(right: 3.w),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_selectedMonth $_selectedYear',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: _showFilterBottomSheet,
              icon: CustomIconWidget(
                iconName: 'tune',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar por local, data ou notas...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                    size: 20,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
            ),
          ),

          // Statistics Summary
          StatisticsSummaryWidget(),

          // Route List
          Expanded(
            child: _filteredRoutes.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshRoutes,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: _filteredRoutes.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _filteredRoutes.length) {
                          return _buildLoadingIndicator();
                        }

                        final route = _filteredRoutes[index];
                        final routeId = route['id'] as int;
                        final isSelected = _selectedRoutes.contains(routeId);

                        return GestureDetector(
                          onLongPress: () {
                            if (!_isMultiSelectMode) {
                              _toggleMultiSelectMode();
                            }
                            _toggleRouteSelection(routeId);
                          },
                          onTap: () {
                            if (_isMultiSelectMode) {
                              _toggleRouteSelection(routeId);
                            } else {
                              Navigator.pushNamed(context, '/route-details');
                            }
                          },
                          child: RouteCardWidget(
                            route: route,
                            isMultiSelectMode: _isMultiSelectMode,
                            isSelected: isSelected,
                            onSwipeRight: (routeData) =>
                                _showQuickActions(routeData),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/gps-tracking-screen'),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              child: CustomIconWidget(
                iconName: 'add_road',
                color: Colors.white,
                size: 24,
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImageWidget(
              imageUrl:
                  "https://images.pexels.com/photos/163210/motorcycles-race-helmets-pilots-163210.jpeg?auto=compress&cs=tinysrgb&w=300",
              width: 60.w,
              height: 30.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 4.h),
            Text(
              'Nenhuma aventura ainda',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Comece sua primeira aventura de moto e crie memórias inesquecíveis!',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/gps-tracking-screen'),
              icon: CustomIconWidget(
                iconName: 'navigation',
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Iniciar Primeira Aventura'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  void _showQuickActions(Map<String, dynamic> route) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Compartilhar Rota'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rota compartilhada!')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: AppTheme.successLight,
                size: 24,
              ),
              title: const Text('Exportar GPX'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Arquivo GPX exportado!')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.errorLight,
                size: 24,
              ),
              title: const Text('Excluir Viagem'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(route);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Viagem'),
        content: Text('Deseja excluir a viagem "${route['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Viagem excluída!')),
              );
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: AppTheme.errorLight),
            ),
          ),
        ],
      ),
    );
  }
}
