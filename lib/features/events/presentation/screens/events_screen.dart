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
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  final List<String> _tabs = ['Upcoming', 'Past', 'My Events', 'Featured'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Simulate loading data
    _loadEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
        _isLoading = true;
      });
      _loadEvents();
    }
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
    });
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
              title: const Text('Community Events'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Show search
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Show filters
                  },
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
        body: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) {
            if (_isLoading) {
              return _buildLoadingList();
            }
            
            if (_events.isEmpty) {
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
                      'Check back later for upcoming events',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // Fixed: Use ListView.builder directly without padding to avoid overflow
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                
                // Fixed: Wrap with SizedBox to constrain height and prevent overflow
                return SizedBox(
                  // No fixed height - let items size naturally within ListView
                  width: double.infinity,
                  child: Padding(
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
                  ),
                );
              },
            );
          }).toList(),
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
      height: 280, // Fixed height for loading item
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 16),
                Container(
                  height: 16,
                  width: double.infinity,
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