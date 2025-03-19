// lib/features/community/presentation/screens/community_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/buttons/animated_button.dart';
import '../../../../core/models/community_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../widgets/communtiy_card.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isLoading = true;
  List<CommunityModel> _myCommunities = [];
  List<CommunityModel> _recommendedCommunities = [];
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }
  
  Future<void> _loadCommunities() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Get current user communities
      if (authService.currentUser != null) {
        final userId = authService.currentUser!.id;
        
        // Load user's communities
        final userCommunities = await firestoreService.getCommunities(
          userId: userId,
          joinedOnly: true,
          limit: 10,
        );
        
        // Load recommended communities (not joined by the user)
        final allCommunities = await firestoreService.getCommunities(
          limit: 10,
        );
        
        // Filter out communities the user is already a member of
        final joinedCommunityIds = userCommunities.map((c) => c.id).toSet();
        final recommendedCommunities = allCommunities
            .where((community) => !joinedCommunityIds.contains(community.id))
            .toList();
        
        if (mounted) {
          setState(() {
            _myCommunities = userCommunities;
            _recommendedCommunities = recommendedCommunities;
            _isLoading = false;
          });
        }
      } else {
        // User is not logged in, just show recommended communities
        final allCommunities = await firestoreService.getCommunities(
          limit: 10,
        );
        
        if (mounted) {
          setState(() {
            _recommendedCommunities = allCommunities;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading communities: $e';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _navigateToCommunityDetails(String communityId) {
    context.pushNamed(
      RouteNames.communityDetails,
      pathParameters: {'id': communityId},
    );
  }
  
  void _navigateToCommunityCreate() {
    context.pushNamed(RouteNames.communityCreate);
  }
  
  void _navigateToCommunityBrowse() {
    context.pushNamed(RouteNames.communities);
  }
  
  void _joinCommunity(CommunityModel community) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    try {
      if (authService.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to join communities'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final userId = authService.currentUser!.id;
      
      if (community.isPrivate) {
        // Request to join private community
        await firestoreService.requestJoinCommunity(
          community.id,
          userId,
          authService.currentUser!.name,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request to join community sent'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        // Join public community
        await firestoreService.joinCommunity(community.id, userId);
        
        // Add to user's communities list
        final updatedCommunities = [...authService.currentUser!.communities, community.id];
        await authService.updateCommunities(updatedCommunities);
        
        // Refresh the communities list
        _loadCommunities();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined community'),
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
    final authService = Provider.of<AuthService>(context);
    final hasJoinedCommunities = _myCommunities.isNotEmpty;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _navigateToCommunityBrowse,
            tooltip: 'Browse Communities',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCommunities,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadCommunities,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with create button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Communities',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _navigateToCommunityCreate,
                          icon: const Icon(Icons.add),
                          label: const Text('Create'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  
                  // My Communities
                  if (authService.isLoggedIn) ...[
                    if (hasJoinedCommunities) ...[
                      // User has joined communities
                      ListView.builder(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _myCommunities.length,
                        itemBuilder: (context, index) {
                          final community = _myCommunities[index];
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CommunityCard(
                              id: community.id,
                              name: community.name,
                              description: community.description,
                              imageUrl: community.imageUrl,
                              memberCount: community.memberIds.length,
                              isJoined: true,
                              isPrivate: community.isPrivate,
                              onTap: () => _navigateToCommunityDetails(community.id),
                            ),
                          ).animate().fadeIn(
                            duration: 300.ms,
                            delay: Duration(milliseconds: 100 * index),
                          );
                        },
                      ),
                    ] else ...[
                      // No joined communities
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.group_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'You haven\'t joined any communities yet',
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              AnimatedGradientButton(
                                text: 'Find Communities',
                                onPressed: _navigateToCommunityBrowse,
                                gradient: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.tertiary,
                                ],
                                width: 200,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                    ],
                  ] else ...[
                    // User not logged in
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.login,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Please log in to see your communities',
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            AnimatedGradientButton(
                              text: 'Log In',
                              onPressed: () => context.goNamed(RouteNames.login),
                              gradient: [
                                theme.colorScheme.primary,
                                theme.colorScheme.tertiary,
                              ],
                              width: 200,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                  ],
                  
                  // Recommended Communities
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recommended Communities',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToCommunityBrowse,
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
                  
                  if (_recommendedCommunities.isNotEmpty) ...[
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recommendedCommunities.length > 3 ? 3 : _recommendedCommunities.length,
                      itemBuilder: (context, index) {
                        final community = _recommendedCommunities[index];
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CommunityCard(
                            id: community.id,
                            name: community.name,
                            description: community.description,
                            imageUrl: community.imageUrl,
                            memberCount: community.memberIds.length,
                            isJoined: false,
                            isPrivate: community.isPrivate,
                            onTap: () => _navigateToCommunityDetails(community.id),
                            onJoin: () => _joinCommunity(community),
                          ),
                        ).animate().fadeIn(
                          duration: 300.ms,
                          delay: Duration(milliseconds: 500 + (index * 100)),
                        );
                      },
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.search,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No recommended communities available',
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
                  ],
                  
                  // Feature explanation
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Community Features',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureItem(
                            icon: Icons.photo_library,
                            title: 'Photo Sharing',
                            description: 'Share your best moments with community members',
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            icon: Icons.event,
                            title: 'Community Events',
                            description: 'Create and participate in local events',
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            icon: Icons.forum,
                            title: 'Discussions',
                            description: 'Engage in conversations with like-minded people',
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 600.ms).slideY(
                    begin: 0.3,
                    end: 0.0,
                    duration: 300.ms,
                    delay: 600.ms,
                    curve: Curves.easeOutQuad,
                  ),
                ],
              ),
            ),
          ),
    );
  }
  
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}