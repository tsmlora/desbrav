import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/community_service.dart';
import './widgets/create_group_modal_widget.dart';
import './widgets/group_card_widget.dart';
import './widgets/group_category_tabs_widget.dart';

class CommunityGroupsScreen extends StatefulWidget {
  const CommunityGroupsScreen({Key? key}) : super(key: key);

  @override
  State<CommunityGroupsScreen> createState() => _CommunityGroupsScreenState();
}

class _CommunityGroupsScreenState extends State<CommunityGroupsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final CommunityService _communityService = CommunityService();

  bool _isSearching = false;
  String _selectedCategory = 'Meus Grupos';
  List<CommunityGroup> _filteredGroups = [];
  bool _isLoading = true;
  String? _error;
  String? _userLocation;

  final List<String> _categories = [
    'Meus Grupos',
    'Próximos',
    'Populares',
    'Recomendados',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProfile = authProvider.currentUserProfile;

    if (userProfile?.city != null && userProfile?.state != null) {
      _userLocation = '${userProfile!.city}, ${userProfile.state}';
    }

    await _loadGroupsForCategory();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _categories[_tabController.index];
      });
      _loadGroupsForCategory();
    }
  }

  Future<void> _loadGroupsForCategory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      List<CommunityGroup> groups = [];

      switch (_selectedCategory) {
        case 'Meus Grupos':
          if (userId != null) {
            groups = await _communityService.getUserGroups(userId);
          }
          break;
        case 'Próximos':
          if (userId != null) {
            groups = await _communityService.getGroupsNearUser(userId);
          }
          break;
        case 'Populares':
          groups = await _communityService.getPopularGroups(limit: 20);
          break;
        case 'Recomendados':
          if (userId != null) {
            groups = await _communityService.getRecommendedGroups(userId);
          }
          break;
      }

      setState(() {
        _filteredGroups = groups;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _filterGroups() {
    if (_searchController.text.isEmpty) {
      _loadGroupsForCategory();
    } else {
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final groups =
          await _communityService.searchGroups(_searchController.text);

      setState(() {
        _filteredGroups = groups;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      _loadGroupsForCategory();
    } else {
      // Debounce search to avoid too many requests
      Future.delayed(Duration(milliseconds: 500), () {
        if (_searchController.text == value) {
          _performSearch();
        }
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _loadGroupsForCategory();
      }
    });
  }

  void _showCreateGroupModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateGroupModalWidget(
        onGroupCreated: (groupData) {
          // Refresh the current category to show the new group
          _loadGroupsForCategory();
        },
      ),
    );
  }

  Future<void> _onGroupJoinToggle(String groupId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Faça login para participar de grupos'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
        return;
      }

      final isCurrentlyMember =
          await _communityService.isGroupMember(groupId, userId);

      if (isCurrentlyMember) {
        await _communityService.leaveGroup(groupId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Você saiu do grupo'),
            backgroundColor: AppTheme.warningLight,
          ),
        );
      } else {
        await _communityService.joinGroup(groupId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Você entrou no grupo!'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      }

      // Refresh the groups list
      _loadGroupsForCategory();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar participação no grupo'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    await _loadGroupsForCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                style: AppTheme.lightTheme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Buscar grupos...',
                  hintStyle: AppTheme.lightTheme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.textMediumEmphasisLight),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            : Text(
                'Comunidade',
                style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
              ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: CustomIconWidget(
              iconName: _isSearching ? 'close' : 'search',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          if (!_isSearching)
            IconButton(
              onPressed: _showCreateGroupModal,
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.primaryLight,
                size: 24,
              ),
            ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          // Location-based suggestions header
          if (!_isSearching) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(color: AppTheme.dividerLight, width: 1),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'location_on',
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _userLocation != null
                          ? 'Grupos próximos a você em $_userLocation'
                          : 'Grupos próximos a você',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMediumEmphasisLight,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _showCreateGroupModal,
                    child: Text(
                      'Criar Grupo',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Category tabs
            GroupCategoryTabsWidget(
              categories: _categories,
              selectedCategory: _selectedCategory,
              tabController: _tabController,
            ),
          ],
          // Groups list
          Expanded(
            child: _buildGroupsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: AppTheme.errorLight,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                'Erro ao carregar grupos',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textHighEmphasisLight,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Tente novamente em alguns momentos',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: _loadGroupsForCategory,
                child: Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredGroups.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.primaryLight,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        itemCount: _filteredGroups.length,
        itemBuilder: (context, index) {
          final group = _filteredGroups[index];
          return GroupCardWidget(
            group: _convertToMap(group),
            onJoinToggle: () => _onGroupJoinToggle(group.id),
            onTap: () {
              // Navigate to group detail screen
              Navigator.pushNamed(
                context,
                '/group-detail-screen',
                arguments: group.id,
              );
            },
          );
        },
      ),
    );
  }

  Map<String, dynamic> _convertToMap(CommunityGroup group) {
    return {
      "id": group.id,
      "name": group.name,
      "description": group.description ?? "",
      "coverImage": group.coverImageUrl ??
          "https://images.pexels.com/photos/163210/motorcycles-race-helmets-pilots-163210.jpeg",
      "memberCount": group.memberCount,
      "isJoined":
          false, // This will be determined in real-time by the join/leave functions
      "isPrivate": group.visibility != GroupVisibility.public,
      "location": group.locationDisplay,
      "motorcycleType": group.categoryDisplayName,
      "lastActivity": _formatLastActivity(group.lastActivityAt),
      "unreadMessages": 0, // Would come from a messaging system
      "isVerified": group.isVerified,
      "recentPost": "Atividade recente no grupo",
      "category": _selectedCategory,
    };
  }

  String _formatLastActivity(DateTime lastActivity) {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays} dias atrás';
    }
  }

  Widget _buildEmptyState() {
    String emptyMessage;
    String emptyDescription;
    String buttonText;

    switch (_selectedCategory) {
      case 'Meus Grupos':
        emptyMessage = 'Você ainda não participa de nenhum grupo';
        emptyDescription =
            'Encontre grupos da sua região e conecte-se com outros motociclistas';
        buttonText = 'Encontrar Grupos';
        break;
      case 'Próximos':
        emptyMessage = 'Nenhum grupo próximo encontrado';
        emptyDescription =
            'Não encontramos grupos na sua região. Que tal criar o primeiro?';
        buttonText = 'Criar Grupo';
        break;
      case 'Populares':
        emptyMessage = 'Nenhum grupo popular no momento';
        emptyDescription =
            'Verifique novamente mais tarde ou explore outras categorias';
        buttonText = 'Atualizar';
        break;
      case 'Recomendados':
        emptyMessage = 'Nenhuma recomendação disponível';
        emptyDescription =
            'Complete seu perfil para receber recomendações personalizadas';
        buttonText = 'Ir para Perfil';
        break;
      default:
        emptyMessage = 'Nenhum grupo encontrado';
        emptyDescription = 'Tente outros filtros ou crie um novo grupo';
        buttonText = 'Criar Grupo';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'groups',
              color: AppTheme.textMediumEmphasisLight,
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              emptyMessage,
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.textHighEmphasisLight,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              emptyDescription,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textMediumEmphasisLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: () {
                switch (_selectedCategory) {
                  case 'Próximos':
                  case 'Recomendados':
                    _showCreateGroupModal();
                    break;
                  case 'Populares':
                    _loadGroupsForCategory();
                    break;
                  default:
                    // Change to próximos tab to find groups
                    _tabController.animateTo(1);
                }
              },
              style: AppTheme.lightTheme.elevatedButtonTheme.style,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
