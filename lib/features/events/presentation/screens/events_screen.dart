import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/event_model.dart';
import '../widgets/animated_event_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isLoading = true;
  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _isSearching = false;
  bool _showFilterOptions = false;
  
  // Filter options
  bool _filterUpcomingOnly = false;
  bool _filterAttendingOnly = false;
  String? _filterLocation;
  List<String> _filterByTags = [];
  
  final List<String> _tabs = ['Upcoming', 'Past', 'My Events', 'Featured'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _searchController.addListener(_handleSearchChanged);
    
    // Simulate loading data
    _loadEvents();
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
      _loadEvents();
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
      _filterUpcomingOnly = false;
      _filterAttendingOnly = false;
      _filterLocation = null;
      _filterByTags = [];
      _applyFiltersAndSearch();
    });
  }
  
  void _applyFiltersAndSearch() {
    if (_events.isEmpty) return;
    
    setState(() {
      _filteredEvents = List.from(_events);
      
      // Apply search text filter
      if (_searchText.isNotEmpty) {
        _filteredEvents = _filteredEvents.where((event) {
          return event.title.toLowerCase().contains(_searchText.toLowerCase()) ||
                 event.description.toLowerCase().contains(_searchText.toLowerCase()) ||
                 event.organizerName.toLowerCase().contains(_searchText.toLowerCase()) ||
                 event.location.toLowerCase().contains(_searchText.toLowerCase()) ||
                 event.tags.any((tag) => tag.toLowerCase().contains(_searchText.toLowerCase()));
        }).toList();
      }
      
      // Apply upcoming only filter
      if (_filterUpcomingOnly) {
        final now = DateTime.now();
        _filteredEvents = _filteredEvents.where((event) => 
          event.eventDate.isAfter(now)).toList();
      }
      
      // Apply attending only filter
      if (_filterAttendingOnly) {
        _filteredEvents = _filteredEvents.where((event) => 
          event.isAttending).toList();
      }
      
      // Apply location filter
      if (_filterLocation != null && _filterLocation!.isNotEmpty) {
        _filteredEvents = _filteredEvents.where((event) => 
          event.location.toLowerCase().contains(_filterLocation!.toLowerCase())).toList();
      }
      
      // Apply tags filter
      if (_filterByTags.isNotEmpty) {
        _filteredEvents = _filteredEvents.where((event) => 
          event.tags.any((tag) => _filterByTags.contains(tag))).toList();
      }
    });
  }

  Future<void> _loadEvents() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        // Generate different sample data based on selected tab
        switch (_currentTabIndex) {
          case 0: // Upcoming
            _events = EventModel.sampleList(10);
            break;
          case 1: // Past
            _events = EventModel.sampleList(8).reversed.toList();
            break;
          case 2: // My Events
            _events = EventModel.sampleList(5);
            break;
          case 3: // Featured
            _events = EventModel.sampleList(3);
            break;
        }
        
        _filteredEvents = List.from(_events);
        _isLoading = false;
      });
    }
  }

  void _handleEventAttendToggle(String eventId) {
    setState(() {
      final eventIndex = _events.indexWhere((event) => event.id == eventId);
      if (eventIndex != -1) {
        _events[eventIndex] = _events[eventIndex].toggleAttending();
      }
      
      // Also update in filtered list
      final filteredIndex = _filteredEvents.indexWhere((event) => event.id == eventId);
      if (filteredIndex != -1) {
        _filteredEvents[filteredIndex] = _filteredEvents[filteredIndex].toggleAttending();
      }
    });
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
  
  // Build filter options widget
  Widget _buildFilterOptions() {
    final theme = Theme.of(context);
    
    // Generate a list of all unique tags from events
    final allTags = <String>{};
    for (var event in _events) {
      allTags.addAll(event.tags);
    }
    
    // Generate a list of unique locations
    final locations = <String>{};
    for (var event in _events) {
      if (event.location.isNotEmpty) {
        locations.add(event.location);
      }
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
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
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
              
              // Upcoming only switch
              SwitchListTile(
                title: const Text('Upcoming Events Only'),
                value: _filterUpcomingOnly,
                onChanged: (value) {
                  setState(() {
                    _filterUpcomingOnly = value;
                    _applyFiltersAndSearch();
                  });
                },
                dense: true,
              ),
              
              // Attending only switch
              SwitchListTile(
                title: const Text('Events I\'m Attending'),
                value: _filterAttendingOnly,
                onChanged: (value) {
                  setState(() {
                    _filterAttendingOnly = value;
                    _applyFiltersAndSearch();
                  });
                },
                dense: true,
              ),
              
              const Divider(),
              
              // Filter by location
              if (locations.isNotEmpty) ...[
                const Text('Filter by Location:'),
                const SizedBox(height: 8),
                DropdownButton<String?>(
                  value: _filterLocation,
                  hint: const Text('Select Location'),
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _filterLocation = value;
                      _applyFiltersAndSearch();
                    });
                  },
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Locations'),
                    ),
                    ...locations.map((location) {
                      return DropdownMenuItem<String?>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                  ],
                ),
                
                const SizedBox(height: 16),
              ],
              
              // Filter by Tags
              if (allTags.isNotEmpty) ...[
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
              ],
              
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
    final theme = Theme.of(context);
    
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
                      hintText: 'Search events...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.grey.shade600),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    autofocus: true,
                  )
                : const Text('Community Events'),
              actions: [
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: _toggleSearch,
                ),
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
                  color: theme.colorScheme.secondaryContainer,
                ),
                labelColor: theme.colorScheme.onSecondaryContainer,
                unselectedLabelColor: theme.colorScheme.onSurface,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                splashBorderRadius: BorderRadius.circular(50),
              ),
            ),
          ];
        },
        body: SafeArea(
          child: Column(
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
                    
                    if (_filteredEvents.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events found',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try changing your filters',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (_searchText.isNotEmpty || 
                                _filterUpcomingOnly || 
                                _filterAttendingOnly ||
                                _filterLocation != null ||
                                _filterByTags.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _resetFilters,
                                child: const Text('Reset filters'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                    
                    // Use ListView.builder with SafeArea to prevent overflow
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AnimatedEventCard(
                            id: event.id,
                            title: event.title,
                            description: event.description,
                            imageUrl: event.imageUrl,
                            eventDate: event.eventDate,
                            location: event.location,
                            organizerName: event.organizerName,
                            attendeeCount: event.attendeeCount,
                            isAttending: event.isAttending,
                            onAttendToggle: () => _handleEventAttendToggle(event.id),
                            index: index,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
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