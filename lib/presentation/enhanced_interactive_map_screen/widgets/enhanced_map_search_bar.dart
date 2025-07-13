import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/models/business.dart';
import '../../../core/services/map_service.dart';

class EnhancedMapSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final MapService mapService;
  final Function(Business) onLocationSelected;

  const EnhancedMapSearchBar({
    Key? key,
    required this.onSearchChanged,
    required this.mapService,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<EnhancedMapSearchBar> createState() => _EnhancedMapSearchBarState();
}

class _EnhancedMapSearchBarState extends State<EnhancedMapSearchBar>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Timer? _debounceTimer;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _searchController.text.isNotEmpty) {
      _showSuggestionsPanel();
    } else {
      _hideSuggestionsPanel();
    }
  }

  void _onSearchChanged(String query) {
    widget.onSearchChanged(query);

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      _hideSuggestionsPanel();
      return;
    }

    // Show loading state
    setState(() {
      _isSearching = true;
    });

    // Debounce search requests
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final suggestions = await widget.mapService.searchBusinesses(query);

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isSearching = false;
        });

        if (suggestions.isNotEmpty && _focusNode.hasFocus) {
          _showSuggestionsPanel();
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    }
  }

  void _showSuggestionsPanel() {
    setState(() {
      _showSuggestions = true;
    });
    _animationController.forward();
  }

  void _hideSuggestionsPanel() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showSuggestions = false;
        });
      }
    });
  }

  void _onSuggestionTapped(Map<String, dynamic> suggestion) {
    _searchController.text = suggestion['title'];
    _focusNode.unfocus();
    _hideSuggestionsPanel();

    // Create a business object from suggestion
    final business = Business(
      id: suggestion['id'],
      name: suggestion['title'],
      businessType: suggestion['type'],
      status: 'active',
      latitude: 0.0, // Will be filled by actual business details
      longitude: 0.0,
      address: suggestion['subtitle'],
      city: '',
      state: '',
      country: 'Brasil',
      amenities: [],
      averageRating: suggestion['rating']?.toDouble() ?? 0.0,
      totalReviews: 0,
      imageUrls: [],
      isVerified: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onLocationSelected(business);
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
    setState(() {
      _suggestions = [];
      _isSearching = false;
    });
    _hideSuggestionsPanel();
  }

  Color _getBusinessTypeColor(String type) {
    switch (type) {
      case 'gas_station':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'workshop':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'restaurant':
        return AppTheme.successLight;
      case 'hotel':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'tourist_spot':
        return AppTheme.accentLight;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getBusinessTypeIcon(String type) {
    switch (type) {
      case 'gas_station':
        return 'local_gas_station';
      case 'workshop':
        return 'build';
      case 'restaurant':
        return 'restaurant';
      case 'hotel':
        return 'hotel';
      case 'tourist_spot':
        return 'place';
      default:
        return 'place';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar postos, oficinas, restaurantes...',
              hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty || _isSearching
                  ? Padding(
                      padding: EdgeInsets.all(3.w),
                      child: _isSearching
                          ? SizedBox(
                              width: 5.w,
                              height: 5.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: _clearSearch,
                              child: CustomIconWidget(
                                iconName: 'clear',
                                color: AppTheme.lightTheme.colorScheme.outline,
                                size: 5.w,
                              ),
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

        // Suggestions panel
        if (_showSuggestions && _suggestions.isNotEmpty)
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -10 * (1 - _fadeAnimation.value)),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    margin: EdgeInsets.only(top: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppTheme.lightTheme.dividerColor,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'location_on',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Resultados da busca',
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_suggestions.length} encontrados',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Suggestions list
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 40.h,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _suggestions.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: AppTheme.lightTheme.dividerColor,
                            ),
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _onSuggestionTapped(suggestion),
                                  borderRadius: index == 0
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        )
                                      : index == _suggestions.length - 1
                                          ? const BorderRadius.only(
                                              bottomLeft: Radius.circular(16),
                                              bottomRight: Radius.circular(16),
                                            )
                                          : BorderRadius.zero,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.5.h,
                                    ),
                                    child: Row(
                                      children: [
                                        // Business type icon
                                        Container(
                                          width: 10.w,
                                          height: 10.w,
                                          decoration: BoxDecoration(
                                            color: _getBusinessTypeColor(
                                                    suggestion['type'])
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: CustomIconWidget(
                                              iconName: _getBusinessTypeIcon(
                                                  suggestion['type']),
                                              color: _getBusinessTypeColor(
                                                  suggestion['type']),
                                              size: 5.w,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 3.w),

                                        // Business info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                suggestion['title'],
                                                style: AppTheme.lightTheme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: AppTheme.lightTheme
                                                      .colorScheme.onSurface,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Text(
                                                suggestion['subtitle'],
                                                style: AppTheme.lightTheme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: AppTheme.lightTheme
                                                      .colorScheme.outline,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Rating
                                        if (suggestion['rating'] != null &&
                                            suggestion['rating'] > 0)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.w,
                                              vertical: 0.5.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.successLight
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CustomIconWidget(
                                                  iconName: 'star',
                                                  color: AppTheme.successLight,
                                                  size: 3.w,
                                                ),
                                                SizedBox(width: 1.w),
                                                Text(
                                                  suggestion['rating']
                                                      .toStringAsFixed(1),
                                                  style: AppTheme.lightTheme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color:
                                                        AppTheme.successLight,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
