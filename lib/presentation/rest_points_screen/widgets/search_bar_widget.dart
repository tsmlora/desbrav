import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final String currentLocation;
  final Function(String) onLocationChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.currentLocation,
    required this.onLocationChanged,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _isExpanded = false;
  final FocusNode _focusNode = FocusNode();

  final List<String> _popularLocations = [
    'São Paulo, SP',
    'Rio de Janeiro, RJ',
    'Belo Horizonte, MG',
    'Salvador, BA',
    'Brasília, DF',
    'Curitiba, PR',
    'Recife, PE',
    'Porto Alegre, RS',
    'Fortaleza, CE',
    'Manaus, AM',
  ];

  final List<String> _recentSearches = [
    'Campos do Jordão, SP',
    'Gramado, RS',
    'Bonito, MS',
    'Serra da Mantiqueira',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });
    });
  }

  void _selectLocation(String location) {
    widget.controller.text = location;
    widget.onLocationChanged(location);
    _focusNode.unfocus();
  }

  void _clearSearch() {
    widget.controller.clear();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Buscar localização...',
              hintStyle: TextStyle(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            onChanged: (value) {
              setState(() {});
            },
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                widget.onLocationChanged(value);
                _focusNode.unfocus();
              }
            },
          ),
        ),
        // Search suggestions
        if (_isExpanded)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_recentSearches.isNotEmpty) ...[
                  _buildSectionHeader('Buscas Recentes'),
                  ...(_recentSearches.take(3).map((location) =>
                      _buildLocationSuggestion(location, 'history'))),
                ],
                _buildSectionHeader('Destinos Populares'),
                ...(_popularLocations.take(5).map((location) =>
                    _buildLocationSuggestion(location, 'location_on'))),
                // Current location option
                _buildLocationSuggestion(
                    'Usar Localização Atual', 'my_location'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      child: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLocationSuggestion(String location, String iconName) {
    return GestureDetector(
      onTap: () => _selectLocation(location),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                location,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
