// File: lib/features/community/presentation/screens/community_browse_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/community_model.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/buttons/animated_button.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _loadCommunities();
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

  Future<void> _loadCommunities() async {
    setState(() {
      _isLoading = true;
    });

    // For demo, generate sample data
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      final sampleCommunities = CommunityModel.sampleList(10);
      
      setState(() {
        _communities = sampleCommunities;
        _filteredCommunities = List.from(sampleCommunities);
        _isLoading = false;
      });
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
      if (_showOnlyJoined) {
        _filteredCommunities = _filteredCommunities.where(
          (community) => community.memberIds.contains('current_user_id') // Replace with actual user ID
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isLoading 
            ? const Text('Communities')
            : TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search communities...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back or to main
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
            onPressed: _toggleJoinedFilter,
            tooltip: _showOnlyJoined ? 'Show all communities' : 'Show joined communities',
          ),
          // Search icon (toggle)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _searchController.clear();
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _showOnlyJoined 
                  ? 'You are not a member of any communities yet'
                  : 'No communities found',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            AnimatedGradientButton(
              text: 'Create a Community',
              onPressed: _navigateToCreateCommunity,
              gradient: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ],
              width: 200,
              icon: const Icon(
                Icons.add_circle,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCommunities.length,
      itemBuilder: (context, index) {
        final community = _filteredCommunities[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CommunityCard(
            id: community.id,
            name: community.name,
            description: community.description,
            imageUrl: community.imageUrl,
            memberCount: community.memberIds.length,
            isJoined: community.memberIds.contains('current_user_id'), // Replace with actual user ID
            isPrivate: community.isPrivate,
            onTap: () => _navigateToCommunityDetails(community.id),
          ),
        );
      },
    );
  }
}