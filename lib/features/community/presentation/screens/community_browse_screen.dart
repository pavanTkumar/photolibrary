import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/community_model.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/buttons/animated_button.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../widgets/communtiy_card.dart';

class CommunityBrowseScreen extends StatefulWidget {
  const CommunityBrowseScreen({Key? key}) : super(key: key);

  @override
  State<CommunityBrowseScreen> createState() => _CommunityBrowseScreenState();
}

class _CommunityBrowseScreenState extends State<CommunityBrowseScreen> {
  bool _isLoading = true;
  List<CommunityModel> _communities = [];
  List<CommunityModel> _filteredCommunities = [];
  
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _showOnlyJoined = false;
  bool _isUserLoggedIn = false;
  Set<String> _userCommunityIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _checkAuthAndLoadCommunities();
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {
      _searchText = _searchController.text;
      _applySortAndFilter();
    });
  }

  Future<void> _checkAuthAndLoadCommunities() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _isUserLoggedIn = authService.isLoggedIn;
      if (_isUserLoggedIn && authService.currentUser != null) {
        _userCommunityIds = Set.from(authService.currentUser!.communities);
      } else {
        _userCommunityIds = {};
      }
    });
    
    await _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      
      List<CommunityModel> communities;
      
      if (_showOnlyJoined && authService.isLoggedIn && authService.currentUser != null) {
        // Load only the communities the user has joined
        communities = await firestoreService.getCommunities(
          userId: authService.currentUser!.id,
          joinedOnly: true,
          limit: 50,
        );
      } else {
        // Load all communities
        communities = await firestoreService.getCommunities(
          limit: 50,
        );
      }
      
      // Update the user's community ids if logged in
      if (authService.isLoggedIn && authService.currentUser != null) {
        _userCommunityIds = Set.from(authService.currentUser!.communities);
      }
      
      if (mounted) {
        setState(() {
          _communities = communities;
          _filteredCommunities = List.from(communities);
          _applySortAndFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading communities: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applySortAndFilter() {
    if (_communities.isEmpty) return;
    
    setState(() {
      _filteredCommunities = List.from(_communities);
      
      // Apply search filter
      if (_searchText.isNotEmpty) {
        _filteredCommunities = _filteredCommunities.where((community) {
          return community.name.toLowerCase().contains(_searchText.toLowerCase()) ||
                 community.description.toLowerCase().contains(_searchText.toLowerCase());
        }).toList();
      }
      
      // Show only joined communities if filter is on
      if (_showOnlyJoined && _isUserLoggedIn) {
        _filteredCommunities = _filteredCommunities.where(
          (community) => _userCommunityIds.contains(community.id)
        ).toList();
      }
    });
  }

  void _toggleJoinedFilter() {
    setState(() {
      _showOnlyJoined = !_showOnlyJoined;
      _applySortAndFilter();
    });
  }

  void _navigateToCreateCommunity() {
    context.pushNamed(RouteNames.communityCreate);
  }

  void _navigateToCommunityDetails(String communityId) {
    context.pushNamed(
      RouteNames.communityDetails,
      pathParameters: {'id': communityId},
    );
  }
  
  Future<void> _joinCommunity(CommunityModel community) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    if (!authService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to join communities'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User profile not loaded. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      final userId = authService.currentUser!.id;
      
      if (community.isPrivate) {
        // For private communities, request to join
        await firestoreService.requestJoinCommunity(
          community.id, 
          userId, 
          authService.currentUser!.name
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request to join sent. Awaiting approval.'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        // For public communities, join directly
        await firestoreService.joinCommunity(community.id, userId);
        
        // Update local data to reflect the change
        setState(() {
          _userCommunityIds.add(community.id);
          // Update community to show as joined in the UI
          final index = _filteredCommunities.indexWhere((c) => c.id == community.id);
          if (index != -1) {
            final updatedCommunity = _filteredCommunities[index].copyWith(
              memberIds: [..._filteredCommunities[index].memberIds, userId],
            );
            _filteredCommunities[index] = updatedCommunity;
          }
        });
        
        // Update user's communities list in auth service
        await authService.updateCommunities([
          ...authService.currentUser!.communities, 
          community.id
        ]);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined community!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error joining community: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _searchController.text.isEmpty 
            ? const Text('Browse Communities')
            : TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search communities...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                autofocus: true,
              ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.goNamed(RouteNames.main);
            }
          },
        ),
        actions: [
          // Filter toggle
          IconButton(
            icon: Icon(
              _showOnlyJoined ? Icons.filter_list_off : Icons.filter_list,
              color: _showOnlyJoined ? theme.colorScheme.primary : null,
            ),
            onPressed: _isUserLoggedIn ? _toggleJoinedFilter : null,
            tooltip: _showOnlyJoined ? 'Show all communities' : 'Show joined communities',
          ),
          // Search icon (toggle)
          IconButton(
            icon: Icon(_searchController.text.isEmpty ? Icons.search : Icons.clear),
            onPressed: () {
              setState(() {
                if (_searchController.text.isNotEmpty) {
                  _searchController.clear();
                } else {
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _buildCommunityList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateCommunity,
        tooltip: 'Create Community',
        child: const Icon(Icons.group_add),
      ).animate().scale(
        duration: 300.ms,
        curve: Curves.easeOutBack,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading communities...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityList() {
    if (_filteredCommunities.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadCommunities,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredCommunities.length,
        itemBuilder: (context, index) {
          final community = _filteredCommunities[index];
          final isJoined = _userCommunityIds.contains(community.id);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CommunityCard(
              id: community.id,
              name: community.name,
              description: community.description,
              imageUrl: community.imageUrl,
              memberCount: community.memberIds.length,
              isJoined: isJoined,
              isPrivate: community.isPrivate,
              onTap: () => _navigateToCommunityDetails(community.id),
              onJoin: isJoined ? null : () => _joinCommunity(community),
            ),
          ).animate().fade(
            duration: 300.ms,
            delay: Duration(milliseconds: 50 * index),
          ).slideY(
            begin: 0.2,
            end: 0.0,
            duration: 300.ms,
            delay: Duration(milliseconds: 50 * index),
            curve: Curves.easeOutQuad,
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    String message;
    IconData icon;
    VoidCallback action;
    String actionText;
    
    if (_searchText.isNotEmpty) {
      message = 'No communities found matching "${_searchText}"';
      icon = Icons.search_off;
      action = () {
        _searchController.clear();
      };
      actionText = 'Clear Search';
    } else if (_showOnlyJoined) {
      message = 'You haven\'t joined any communities yet';
      icon = Icons.group_off;
      action = _toggleJoinedFilter;
      actionText = 'Show All Communities';
    } else {
      message = 'No communities available';
      icon = Icons.groups;
      action = _navigateToCreateCommunity;
      actionText = 'Create Community';
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AnimatedGradientButton(
            text: actionText,
            onPressed: action,
            gradient: [
              theme.colorScheme.primary,
              theme.colorScheme.tertiary,
            ],
          ),
        ],
      ),
    );
  }
}