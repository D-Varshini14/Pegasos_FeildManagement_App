import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_visit_screen.dart';
import 'expense_screen.dart';
import 'expense_form_screen.dart';
import 'client_summary_screen.dart';
import 'notifications_screen.dart';
import '../services/api_service.dart';

class TasksScreen extends StatefulWidget {
  final String? initialFilter;

  const TasksScreen({super.key, this.initialFilter});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
  List<Visit> visits = [];
  bool isLoading = true;
  TabController? _tabController;
  String selectedFilter = 'All';
  String _userId = ''; // USER ID FOR DATA ISOLATION
  String _searchQuery = ''; // Search query
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color lightGray = Color(0xFFF1F5F9);
  static const Color cardBackground = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    if (widget.initialFilter != null && widget.initialFilter!.isNotEmpty) {
      selectedFilter = widget.initialFilter!;
    }
    _initializeUser(); // Load user first
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Load user ID first
  Future<void> _initializeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString != null) {
        final userData = jsonDecode(userString);
        _userId = userData['employeeId'] ?? userData['id']?.toString() ?? 'default';
      } else {
        _userId = 'default';
      }

      debugPrint('✅ User initialized in TasksScreen: $_userId');

      // Now load visits
      await _loadVisits();
    } catch (e) {
      debugPrint('❌ Error initializing user: $e');
      _userId = 'default';
      await _loadVisits();
    }
  }

  Future<void> _loadVisits() async {
    setState(() => isLoading = true);
    try {
      // Load only tasks now
      final taskRes = await ApiService.getTasks();

      List<Visit> combined = [];

      if (taskRes['success'] == true && taskRes['data'] != null) {
        final List data = taskRes['data'];
        combined.addAll(data.map((e) {
          final visit = Visit.fromJson(e as Map<String, dynamic>);
          return visit;
        }));
      }

      if (combined.isNotEmpty) {
        setState(() {
          visits = combined;
          visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
          isLoading = false;
        });
        await _saveVisits();
        return;
      }
    } catch (e) {
      debugPrint('ℹ️ API load failed, falling back to local: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String visitsKey = 'visits_$_userId';
      final visitsString = prefs.getString(visitsKey);

      if (visitsString != null) {
        final List<dynamic> visitsJson = jsonDecode(visitsString);
        setState(() {
          visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
          visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
          isLoading = false;
        });
      } else {
        setState(() {
          visits = [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading visits: $e');
      setState(() {
        visits = [];
        isLoading = false;
      });
    }
  }

  Future<void> _saveVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Use user-specific key
      final String visitsKey = 'visits_$_userId';
      final visitsJson = visits.map((visit) => visit.toJson()).toList();
      await prefs.setString(visitsKey, jsonEncode(visitsJson));

      debugPrint('✅ Saved ${visits.length} visits for user: $_userId');
    } catch (e) {
      debugPrint('❌ Error saving visits: $e');
    }
  }

  Future<void> _addVisit(Visit visit) async {
    setState(() {
      visits.add(visit);
      visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
    });
    await _saveVisits();
    debugPrint('✅ Visit added: ${visit.clientName}');
  }

  // Mark task as completed with current timestamp
  Future<void> _markAsCompleted(Visit visit) async {
    if (visit.id == null) {
      _showErrorSnackBar('Cannot update task without ID');
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await ApiService.updateTaskStatus(visit.id!, 'completed');
          
      if (response['success'] == true) {
        await _loadVisits(); // Refresh list from API
        debugPrint('✅ Visit marked as completed on backend');
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateVisitStatus(Visit visit, String newStatus) async {
    if (visit.id == null) {
      _showErrorSnackBar('Cannot update task without ID');
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await ApiService.updateTaskStatus(visit.id!, newStatus);
          
      if (response['success'] == true) {
        await _loadVisits(); // Refresh list from API
        debugPrint('✅ Visit status updated on backend: ${visit.clientName} -> $newStatus');
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _deleteVisit(Visit visit) async {
    if (visit.id == null) {
      _showErrorSnackBar('Cannot delete task without ID');
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await ApiService.deleteTask(visit.id!);
      if (response['success'] == true) {
        await _loadVisits(); // Refresh list from API
        debugPrint('✅ Visit deleted on backend: ${visit.clientName}');
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to delete task');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not call $phone'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _mailVisit(Visit visit) async {
    final subject = Uri.encodeComponent('Visit Update: ${visit.clientName}');
    final body = Uri.encodeComponent(
      'Client: ${visit.clientName}\n'
      'Title: ${visit.purpose}\n'
      'Location: ${visit.location}\n'
      'Date: ${DateFormat('dd MMMM yyyy, HH:mm').format(visit.visitTime)}\n'
      'Status: ${_getStatusDisplayText(visit.status)}\n'
      'Notes: ${visit.notes}',
    );
    final uri = Uri.parse('mailto:?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showDeleteConfirmation(Visit visit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Visit'),
        content: Text('Are you sure you want to delete the visit with ${visit.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteVisit(visit);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<Visit> _getFilteredTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // First apply filter
    List<Visit> filtered;
    switch (selectedFilter) {
      case 'Today':
        filtered = visits.where((visit) {
          final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
          return visitDate == today && visit.status == 'pending';
        }).toList();
        break;
      case 'Upcoming':
        filtered = visits.where((visit) {
          final visitDate = DateTime(visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
          return visitDate.isAfter(today) && visit.status == 'pending';
        }).toList();
        break;
      case 'Completed':
        filtered = visits.where((visit) => visit.status == 'completed' || visit.status == 'successfully_met').toList();
        break;
      case 'Missed':
        filtered = visits.where((visit) => visit.status == 'missed').toList();
        break;
      default:
        filtered = visits;
    }

    // Then apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((visit) {
        return visit.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            visit.purpose.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            visit.location.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visitDate = DateTime(date.year, date.month, date.day);
    return visitDate == today;
  }

  void _navigateToExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseScreen()),
    );
  }

  void _navigateToExpenseForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseScreen()),
    );
  }

  void _navigateToClientSummary(Visit specificVisit) {
    debugPrint('Navigating to summary for: ${specificVisit.clientName}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ClientSummaryScreen(selectedVisit: specificVisit);
        },
      ),
    ).then((result) {
      if (result == true) {
        _loadVisits();
      }
    });
  }

  void _showVisitSelectionDialog() {
    if (visits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No visits scheduled yet'),
          backgroundColor: primaryBlue,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Visit for Summary'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryBlue.withOpacity(0.1),
                      child: Text(
                        visit.clientName[0].toUpperCase(),
                        style: const TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      visit.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(visit.purpose),
                        Text(
                          'Status: ${_getStatusDisplayText(visit.status)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(visit.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToClientSummary(visit);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'completed':
      case 'successfully_met':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'missed':
        return 'Missed';
      case 'client_not_available':
        return 'Client Not Available';
      case 'postponed':
        return 'Postponed';
      case 'cancelled':
        return 'Cancelled';
      case 'in_progress':
        return 'In Progress';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
      case 'successfully_met':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'missed':
        return Colors.red;
      case 'client_not_available':
        return Colors.grey;
      case 'postponed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return primaryBlue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tasks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 24),
            onPressed: () => _logout(context),
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: primaryBlue,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by client name, purpose or location',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          Container(
            color: lightGray,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['All', 'Today', 'Upcoming', 'Completed', 'Missed']
                    .map((filter) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedFilter == filter ? primaryBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: selectedFilter == filter ? Colors.white : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryBlue))
                : _getFilteredTasks().isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadVisits,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _getFilteredTasks().length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final visit = _getFilteredTasks()[index];
                  return _buildTaskCard(visit);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddVisitScreen(),
            ),
          );

          if (result == true) {
            await _loadVisits();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visit scheduled successfully!'),
                  backgroundColor: Color(0xFF4CAF50),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavItem(
                  icon: Icons.receipt_long,
                  label: 'Expense',
                  onTap: _navigateToExpense,
                ),

                _buildBottomNavItem(
                  icon: Icons.people_outline,
                  label: 'Client Summary',
                  onTap: () => _showVisitSelectionDialog(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primaryBlue, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty
                ? 'No results found'
                : 'No Tasks Found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try searching with different keywords'
                : selectedFilter == 'All'
                ? 'No tasks scheduled yet.\nTap + to add your first visit.'
                : 'No $selectedFilter tasks found.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Visit visit) {
    final isToday = _isToday(visit.visitTime);
    final isCompleted = visit.status == 'completed' || visit.status == 'successfully_met';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            visit.clientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(visit.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusDisplayText(visit.status),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(visit.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visit.purpose,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                  onPressed: () => _makeCall(visit.phoneNumber),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: primaryBlue),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  visit.location,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening map...'),
                      backgroundColor: primaryBlue,
                    ),
                  );
                },
                child: Text(
                  'Open Map',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                _formatTime(visit.visitTime),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (visit.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryBlue.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes, size: 14, color: primaryBlue),
                      const SizedBox(width: 6),
                      const Text(
                        'Notes:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visit.notes,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Primary action row
          if (!isCompleted) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Mark Complete button
                ElevatedButton.icon(
                  onPressed: () async {
                    await _markAsCompleted(visit);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Visit completed on ${DateFormat('MMM dd, yyyy').format(DateTime.now())}'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Complete', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    minimumSize: const Size(0, 32),
                  ),
                ),
                
                // Mark Pending (Only for Missed tasks)
                if (visit.status == 'missed')
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (visit.id == null) return;
                      final result = await ApiService.updateTaskStatus(visit.id!, 'pending');
                      if (result['success'] == true) {
                        _loadVisits();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task marked as pending'), backgroundColor: Colors.orange),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Pending', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[50],
                      foregroundColor: Colors.orange[700],
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      minimumSize: const Size(0, 32),
                    ),
                  ),

                // Edit button
                ElevatedButton.icon(
                  onPressed: () => _showEditTaskDialog(visit),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    minimumSize: const Size(0, 32),
                  ),
                ),

                // Delete button
                ElevatedButton.icon(
                  onPressed: () => _showDeleteConfirmation(visit),
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text('Delete', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Completed task — LOCKED: only View Summary allowed
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.green[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'This task is completed and locked',
                      style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToClientSummary(visit),
                    icon: const Icon(Icons.visibility, size: 14),
                    label: const Text('View Summary', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryBlue,
                      side: const BorderSide(color: primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          // Mail It button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _mailVisit(visit),
              icon: const Icon(Icons.email_outlined, size: 14),
              label: const Text('Mail It', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal),
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(0, 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit Task Dialog ──
  void _showEditTaskDialog(Visit visit) {
    final titleController = TextEditingController(text: visit.purpose);
    final locationController = TextEditingController(text: visit.location);
    final notesController = TextEditingController(text: visit.notes);
    final phoneController = TextEditingController(text: visit.phoneNumber);
    DateTime selectedDate = visit.visitTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(visit.visitTime);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.edit, color: primaryBlue, size: 22),
                  const SizedBox(width: 8),
                  const Text('Edit Task', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title / Purpose
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title / Purpose',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true, fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Location
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true, fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Phone
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true, fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Date picker
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (c, child) => Theme(
                            data: Theme.of(c).copyWith(
                              colorScheme: const ColorScheme.light(primary: primaryBlue),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = DateTime(
                            picked.year, picked.month, picked.day,
                            selectedTime.hour, selectedTime.minute,
                          ));
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true, fillColor: Colors.grey[50],
                        ),
                        child: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Time picker
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (c, child) => Theme(
                            data: Theme.of(c).copyWith(
                              colorScheme: const ColorScheme.light(primary: primaryBlue),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                            selectedDate = DateTime(
                              selectedDate.year, selectedDate.month, selectedDate.day,
                              picked.hour, picked.minute,
                            );
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true, fillColor: Colors.grey[50],
                        ),
                        child: Text(selectedTime.format(context)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Notes
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        prefixIcon: const Icon(Icons.notes_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true, fillColor: Colors.grey[50],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _editTask(
                      visit,
                      title: titleController.text.trim(),
                      location: locationController.text.trim(),
                      phone: phoneController.text.trim(),
                      notes: notesController.text.trim(),
                      scheduledTime: selectedDate,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editTask(Visit visit, {
    required String title,
    required String location,
    required String phone,
    required String notes,
    required DateTime scheduledTime,
  }) async {
    if (visit.id == null) {
      _showErrorSnackBar('Cannot edit task without ID');
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await ApiService.editTask(visit.id!, {
        'title': title,
        'location': location,
        'client_phone': phone,
        'notes': notes,
        'scheduled_time': scheduledTime.toUtc().toIso8601String(),
      });

      if (response['success'] == true) {
        await _loadVisits();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to update task');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
}