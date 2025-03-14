// File: lib/features/admin/presentation/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/models/event_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<PhotoModel> _pendingPhotos = [];
  List<EventModel> _pendingEvents = [];
  List<Map<String, dynamic>> _memberRequests = [];
  List<Map<String, dynamic>> _reportedContent = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAdminData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAdminData() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        // Generate sample data
        _pendingPhotos = PhotoModel.sampleList(5);
        _pendingEvents = EventModel.sampleList(3);
        
        // Sample member requests
        _memberRequests = List.generate(4, (index) => {
          'id': 'request_$index',
          'name': 'User ${index + 1}',
          'email': 'user${index + 1}@example.com',
          'requestDate': DateTime.now().subtract(Duration(days: index)),
          'avatar': 'https://picsum.photos/seed/user$index/100/100',
        });
        
        // Sample reported content
        _reportedContent = List.generate(3, (index) => {
          'id': 'report_$index',
          'contentType': index % 2 == 0 ? 'photo' : 'comment',
          'reportedBy': 'User ${index + 5}',
          'reportDate': DateTime.now().subtract(Duration(hours: index * 5)),
          'reason': 'Inappropriate content',
          'contentId': index % 2 == 0 ? 'photo_$index' : 'comment_$index',
        });
        
        _isLoading = false;
      });
    }
  }
  
  void _approvePhoto(String photoId) {
    setState(() {
      _pendingPhotos.removeWhere((photo) => photo.id == photoId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo approved and published'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _rejectPhoto(String photoId) {
    setState(() {
      _pendingPhotos.removeWhere((photo) => photo.id == photoId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _approveEvent(String eventId) {
    setState(() {
      _pendingEvents.removeWhere((event) => event.id == eventId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event approved and published'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _rejectEvent(String eventId) {
    setState(() {
      _pendingEvents.removeWhere((event) => event.id == eventId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _approveMemberRequest(String requestId) {
    setState(() {
      _memberRequests.removeWhere((request) => request['id'] == requestId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Member request approved'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _rejectMemberRequest(String requestId) {
    setState(() {
      _memberRequests.removeWhere((request) => request['id'] == requestId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Member request rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _handleReportedContent(String reportId, bool isRemoved) {
    setState(() {
      _reportedContent.removeWhere((report) => report['id'] == reportId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRemoved 
            ? 'Content removed and user notified' 
            : 'Report dismissed'),
        backgroundColor: isRemoved ? Colors.orange : Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Photos'),
            Tab(text: 'Events'),
            Tab(text: 'Requests'),
            Tab(text: 'Reports'),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Photos tab
                _buildPendingPhotosTab(),
                
                // Events tab
                _buildPendingEventsTab(),
                
                // Member requests tab
                _buildMemberRequestsTab(),
                
                // Reported content tab
                _buildReportedContentTab(),
              ],
            ),
    );
  }
  
  Widget _buildPendingPhotosTab() {
    if (_pendingPhotos.isEmpty) {
      return _buildEmptyState('No pending photos to review');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingPhotos.length,
      itemBuilder: (context, index) {
        final photo = _pendingPhotos[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    photo.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Photo details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      photo.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Uploaded by: ${photo.userName}'),
                    Text('Tags: ${photo.tags.join(", ")}'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Reject button
                        OutlinedButton.icon(
                          onPressed: () => _rejectPhoto(photo.id),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Approve button
                        ElevatedButton.icon(
                          onPressed: () => _approvePhoto(photo.id),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: 300.ms,
          delay: (index * 100).ms,
        ).slideY(
          begin: 0.2,
          end: 0,
          duration: 300.ms,
          delay: (index * 100).ms,
          curve: Curves.easeOutQuad,
        );
      },
    );
  }
  
  Widget _buildPendingEventsTab() {
    if (_pendingEvents.isEmpty) {
      return _buildEmptyState('No pending events to review');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingEvents.length,
      itemBuilder: (context, index) {
        final event = _pendingEvents[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Event details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Organized by: ${event.organizerName}'),
                    Text('Date: ${event.eventDate.toString().substring(0, 16)}'),
                    Text('Location: ${event.location}'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Reject button
                        OutlinedButton.icon(
                          onPressed: () => _rejectEvent(event.id),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Approve button
                        ElevatedButton.icon(
                          onPressed: () => _approveEvent(event.id),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: 300.ms,
          delay: (index * 100).ms,
        ).slideY(
          begin: 0.2,
          end: 0,
          duration: 300.ms,
          delay: (index * 100).ms,
          curve: Curves.easeOutQuad,
        );
      },
    );
  }
  
  Widget _buildMemberRequestsTab() {
    if (_memberRequests.isEmpty) {
      return _buildEmptyState('No pending member requests');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _memberRequests.length,
      itemBuilder: (context, index) {
        final request = _memberRequests[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(request['avatar']),
              radius: 30,
            ),
            title: Text(
              request['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request['email']),
                Text(
                  'Requested: ${request['requestDate'].toString().substring(0, 10)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Reject button
                IconButton(
                  onPressed: () => _rejectMemberRequest(request['id']),
                  icon: const Icon(Icons.close),
                  color: Colors.red,
                ),
                
                // Approve button
                IconButton(
                  onPressed: () => _approveMemberRequest(request['id']),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(
          duration: 300.ms,
          delay: (index * 100).ms,
        );
      },
    );
  }
  
  Widget _buildReportedContentTab() {
    if (_reportedContent.isEmpty) {
      return _buildEmptyState('No reported content to review');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reportedContent.length,
      itemBuilder: (context, index) {
        final report = _reportedContent[index];
        final isPhoto = report['contentType'] == 'photo';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isPhoto ? Icons.photo : Icons.comment,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reported ${report['contentType']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      report['reportDate'].toString().substring(0, 16),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Reported by: ${report['reportedBy']}'),
                Text('Reason: ${report['reason']}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Dismiss button
                    OutlinedButton(
                      onPressed: () => _handleReportedContent(report['id'], false),
                      child: const Text('Dismiss Report'),
                    ),
                    const SizedBox(width: 8),
                    
                    // Remove content button
                    ElevatedButton(
                      onPressed: () => _handleReportedContent(report['id'], true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Remove Content'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(
          duration: 300.ms,
          delay: (index * 100).ms,
        );
      },
    );
  }
  
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}