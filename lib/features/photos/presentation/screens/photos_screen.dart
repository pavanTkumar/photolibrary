// File: lib/features/photos/presentation/screens/photos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/router/route_names.dart';
import '../widgets/photo_staggered_grid.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({Key? key}) : super(key: key);

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isLoading = true;
  List<PhotoModel> _photos = [];
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _isSearching = false;
  List<PhotoModel> _filteredPhotos = [];
  
  // Filter options
  bool _filterByLikes = false;
  String? _filterByCommunity;
  List<String> _filterByTags = [];
  bool _showFilterOptions = false;
  
  final List<String> _tabs = ['Recent', 'Popular', 'Following', 'Featured'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _searchController.addListener(_handleSearchChanged);
    
    // Simulate loading data
    _loadPhotos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.removeListener(_handleTabChange);
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
        _isLoading = true;
        // Reset search and filter when tab changes
        _isSearching = false;
        _searchText = '';
        _searchController.clear();
        _showFilterOptions = false;
        _resetFilters();
      });
      _loadPhotos();
    }
  }
  
  void _handleSearchChanged() {
    setState(() {
      _searchText = _searchController.text;
      _applyFiltersAndSearch();
    });
  }
  
  void _resetFilters() {
    setState(() {
      _filterByLikes = false;
      _filterByCommunity = null;
      _filterByTags = [];
      _applyFiltersAndSearch();
    });
  }
  
  void _applyFiltersAndSearch() {
    if (_photos.isEmpty) return;
    
    setState(() {
      _filteredPhotos = List.from(_photos);
      
      // Apply search text filter
      if (_searchText.isNotEmpty) {
        _filteredPhotos = _filteredPhotos.where((photo) {
          return photo.title.toLowerCase().contains(_searchText.toLowerCase()) ||
                 photo.description.toLowerCase().contains(_searchText.toLowerCase()) ||
                 photo.userName.toLowerCase().contains(_searchText.toLowerCase()) ||
                 photo.tags.any((tag) => tag.toLowerCase().contains(_searchText.toLowerCase()));
        }).toList();
      }
      
      // Apply like filter - sort by most likes
      if (_filterByLikes) {
        _filteredPhotos.sort((a, b) => b.likeCount.compareTo(a.likeCount));
      }
      
      // Apply community filter
      if (_filterByCommunity != null) {
        _filteredPhotos = _filteredPhotos.where((photo) => 
          photo.communityId == _filterByCommunity).toList();
      }
      
      // Apply tags filter
      if (_filterByTags.isNotEmpty) {
        _filteredPhotos = _filteredPhotos.where((photo) => 
          photo.tags.any((tag) => _filterByTags.contains(tag))).toList();
      }
    });
  }

  Future<void> _loadPhotos() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        // Generate different sample data based on selected tab
        switch (_currentTabIndex) {
          case 0: // Recent
            _photos = PhotoModel.sampleList(20);
            break;
          case 1: // Popular
            _photos = PhotoModel.sampleList(15).reversed.toList();
            break;
          case 2: // Following
            _photos = PhotoModel.sampleList(10);
            break;
          case 3: // Featured
            _photos = PhotoModel.sampleList(8);
            break;
        }
        
        _filteredPhotos = List.from(_photos);
        _isLoading = false;
      });
    }
  }

  void _handlePhotoLike(String photoId) {
    setState(() {
      final photoIndex = _photos.indexWhere((photo) => photo.id == photoId);
      if (photoIndex != -1) {
        _photos[photoIndex] = _photos[photoIndex].toggleLike();
      }
      
      // Also update in filtered list
      final filteredIndex = _filteredPhotos.indexWhere((photo) => photo.id == photoId);
      if (filteredIndex != -1) {
        _filteredPhotos[filteredIndex] = _filteredPhotos[filteredIndex].toggleLike();
      }
    });
  }

  void _handlePhotoTap(String photoId) {
    // Navigate to photo details screen
    context.pushNamed(
      RouteNames.photoDetails,
      pathParameters: {'id': photoId},
    );
  }
  
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchText = '';
        _applyFiltersAndSearch();
      }
    });
  }
  
  void _toggleFilterOptions() {
    setState(() {
      _showFilterOptions = !_showFilterOptions;
    });
  }
  
  // Build a filter option UI for photo filtering
  Widget _buildFilterOptions() {
    final theme = Theme.of(context);
    
    // Generate a list of all unique tags from photos
    final allTags = <String>{};
    for (var photo in _photos) {
      allTags.addAll(photo.tags);
    }
    
    // Generate a list of all unique communities
    final communities = <String, String>{};
    for (var photo in _photos) {
      // In a real app, you would use community name, but for the sample we'll create mock names
      communities[photo.communityId] = 'Community ${photo.communityId.substring(photo.communityId.length - 1)}';
    }
    
    return Material(
      elevation: 4,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Options',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sort by likes
            SwitchListTile(
              title: const Text('Sort by Most Likes'),
              value: _filterByLikes,
              onChanged: (value) {
                setState(() {
                  _filterByLikes = value;
                  _applyFiltersAndSearch();
                });
              },
              dense: true,
            ),
            
            const Divider(),
            
            // Filter by Community
            const Text('Filter by Community:'),
            const SizedBox(height: 8),
            DropdownButton<String?>(
              value: _filterByCommunity,
              hint: const Text('Select Community'),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  _filterByCommunity = value;
                  _applyFiltersAndSearch();
                });
              },
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Communities'),
                ),
                ...communities.entries.map((entry) {
                  return DropdownMenuItem<String?>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Filter by Tags
            const Text('Filter by Tags:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allTags.map((tag) {
                final isSelected = _filterByTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filterByTags.add(tag);
                      } else {
                        _filterByTags.remove(tag);
                      }
                      _applyFiltersAndSearch();
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Reset Filters button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resetFilters,
                child: const Text('Reset Filters'),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
      begin: -0.3,
      end: 0.0,
      duration: 300.ms,
      curve: Curves.easeOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App bar
            SliverAppBar(
              floating: true,
              snap: true,
              title: _isSearching
                ? TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search photos...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.grey.shade600),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    autofocus: true,
                  )
                : const Text('Community Photos'),
              actions: [
                // Search toggle button
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: _toggleSearch,
                ),
                // Filter toggle button
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _toggleFilterOptions,
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                isScrollable: true,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                splashBorderRadius: BorderRadius.circular(50),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Show filter options if toggled
            if (_showFilterOptions)
              _buildFilterOptions(),
              
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  if (_isLoading) {
                    return _buildLoadingList();
                  }
                  
                  if (_filteredPhotos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No photos found',
                            style: TextStyle(fontSize: 18),
                          ),
                          if (_searchText.isNotEmpty || 
                              _filterByLikes || 
                              _filterByCommunity != null || 
                              _filterByTags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _resetFilters,
                              child: const Text('Reset filters'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  
                  // Display filtered photos
                  return PhotoStaggeredGrid(
                    photos: _filteredPhotos,
                    onLike: _handlePhotoLike,
                    onPhotoTap: _handlePhotoTap,
                    isLoading: _isLoading,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Reduced to prevent overflow
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildLoadingItem(),
        );
      },
    );
  }
  
  Widget _buildLoadingItem() {
    return Container(
      height: 260, // Reduced height to avoid overflow
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // This prevents overflow
        children: [
          // Image placeholder
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          
          // Content placeholders
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // This prevents overflow
              children: [
                Container(
                  height: 24,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    .animate(delay: 300.ms)
    .shimmer(
      duration: 1200.ms,
      color: Colors.white.withOpacity(0.1),
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.2),
        Colors.white.withOpacity(0.1),
      ],
    )
    .animate(
      onPlay: (controller) => controller.repeat(),
    );
  }
}