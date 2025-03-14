// File: lib/features/photos/presentation/widgets/community_selector_dropdown.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/models/community_model.dart';

class CommunitySelectorDropdown extends StatefulWidget {
  final Function(String?) onCommunityChanged;
  final String? initialCommunityId;
  
  const CommunitySelectorDropdown({
    Key? key,
    required this.onCommunityChanged,
    this.initialCommunityId,
  }) : super(key: key);

  @override
  State<CommunitySelectorDropdown> createState() => _CommunitySelectorDropdownState();
}

class _CommunitySelectorDropdownState extends State<CommunitySelectorDropdown> {
  String? _selectedCommunityId;
  List<CommunityModel> _communities = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _selectedCommunityId = widget.initialCommunityId;
    _loadCommunities();
  }
  
  Future<void> _loadCommunities() async {
    // In a real app, this would fetch from Firestore
    // For now, we'll use sample data
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Generate sample data
      final communities = [
        CommunityModel(
          id: 'community_1',
          name: 'Nature Photography',
          description: 'Share your beautiful nature shots',
          imageUrl: 'https://picsum.photos/seed/community1/100/100',
          adminId: 'admin_1',
          adminName: 'Admin User',
          createdAt: DateTime.now().subtract(const Duration(days: 100)),
          memberIds: ['user_1', 'user_2', 'user_3'],
          moderatorIds: ['user_1'],
          isPrivate: false,
        ),
        CommunityModel(
          id: 'community_2',
          name: 'Street Photography',
          description: 'Urban shots and city life',
          imageUrl: 'https://picsum.photos/seed/community2/100/100',
          adminId: 'admin_2',
          adminName: 'Admin User 2',
          createdAt: DateTime.now().subtract(const Duration(days: 50)),
          memberIds: ['user_1', 'user_3'],
          moderatorIds: ['user_3'],
          isPrivate: false,
        ),
        CommunityModel(
          id: 'community_3',
          name: 'Portrait Photography',
          description: 'Beautiful portrait shots',
          imageUrl: 'https://picsum.photos/seed/community3/100/100',
          adminId: 'admin_3',
          adminName: 'Admin User 3',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          memberIds: ['user_2', 'user_3'],
          moderatorIds: [],
          isPrivate: true,
        ),
      ];
      
      setState(() {
        _communities = communities;
        _isLoading = false;
        
        // Set the first community as default if none was specified
        if (_selectedCommunityId == null && communities.isNotEmpty) {
          _selectedCommunityId = communities.first.id;
          widget.onCommunityChanged(_selectedCommunityId);
        }
      });
    } catch (e) {
      debugPrint('Error loading communities: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Dropdown
        _isLoading
            ? const LinearProgressIndicator()
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCommunityId,
                    isExpanded: true,
                    hint: const Text('Select a community'),
                    onChanged: (String? communityId) {
                      setState(() {
                        _selectedCommunityId = communityId;
                      });
                      widget.onCommunityChanged(communityId);
                    },
                    items: _communities.map((community) {
                      return DropdownMenuItem<String>(
                        value: community.id,
                        child: Row(
                          children: [
                            if (community.imageUrl.isNotEmpty) ...[
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(community.imageUrl),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                community.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
        
        const SizedBox(height: 8),
        
        // Helper text
        Text(
          'Select the community where you want to share this photo',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}