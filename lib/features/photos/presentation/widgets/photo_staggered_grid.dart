// File: lib/features/photos/presentation/widgets/photo_staggered_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/router/route_names.dart';
import 'animated_photo_card.dart';

class PhotoStaggeredGrid extends StatelessWidget {
  final List<PhotoModel> photos;
  final Function(String) onLike;
  final Function(String)? onPhotoTap;
  final bool isLoading;
  final ScrollController? scrollController;

  const PhotoStaggeredGrid({
    Key? key,
    required this.photos,
    required this.onLike,
    this.onPhotoTap,
    this.isLoading = false,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading && photos.isEmpty) {
      return _buildLoadingGrid();
    }

    if (photos.isEmpty) {
      return const Center(
        child: Text('No photos yet'),
      );
    }

    return MasonryGridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: photos.length,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemBuilder: (context, index) {
        final photo = photos[index];
        
        return AnimatedPhotoCard(
          id: photo.id,
          imageUrl: photo.imageUrl,
          title: photo.title,
          uploaderName: photo.uploaderName,
          uploadDate: photo.uploadDate,
          likeCount: photo.likeCount,
          isLiked: photo.isLiked,
          onLike: () => onLike(photo.id),
          onTap: () {
            if (onPhotoTap != null) {
              onPhotoTap!(photo.id);
            } else {
              // Default behavior - navigate to photo details
              context.pushNamed(
                RouteNames.photoDetails,
                pathParameters: {'id': photo.id},
              );
            }
          },
          index: index,
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: 6, // Show 6 placeholder items
      itemBuilder: (context, index) {
        return _buildLoadingItem(index);
      },
    );
  }

  Widget _buildLoadingItem(int index) {
    // Use a fixed height instead of varying heights to avoid layout issues
    return Container(
      height: index.isEven ? 200.0 : 240.0,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: constraints.maxHeight * 0.7,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              
              // Content placeholders - Fixed height for these elements
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
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
          );
        }
      ),
    );
  }
}