// File: lib/features/photos/presentation/screens/photos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/router/route_names.dart';
import '../widgets/photo_staggered_grid.dart';
import '../../../../core/widgets/animated_app_bar.dart';

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
  
  final List<String> _tabs = ['Recent', 'Popular', 'Following', 'Featured'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Simulate loading data
    _loadPhotos();
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
      _loadPhotos();
    }
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
    });
  }

  void _handlePhotoTap(String photoId) {
    // Navigate to photo details screen
    context.pushNamed(
      RouteNames.photoDetails,
      pathParameters: {'id': photoId},
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
              title: const Text('Community Photos'),
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
        body: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) {
            return PhotoStaggeredGrid(
              photos: _photos,
              onLike: _handlePhotoLike,
              onPhotoTap: _handlePhotoTap, // Pass the navigation function
              isLoading: _isLoading,
            );
          }).toList(),
        ),
      ),
    );
  }
}