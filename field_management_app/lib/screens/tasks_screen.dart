import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'add_visit_screen.dart';
import 'expense_screen.dart';
import 'expense_form_screen.dart';
import 'client_summary_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

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
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();

      // Use user-specific key
      final String visitsKey = 'visits_$_userId';
      final visitsString = prefs.getString(visitsKey);

      if (visitsString != null) {
        final List<dynamic> visitsJson = jsonDecode(visitsString);
        setState(() {
          visits = visitsJson.map((json) => Visit.fromJson(json)).toList();
          visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));
          isLoading = false;
        });
        debugPrint('✅ Loaded ${visits.length} visits for user: $_userId');
      } else {
        setState(() {
          visits = [];
          isLoading = false;
        });
        debugPrint('ℹ️ No visits found for user: $_userId');
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
    final index = visits.indexWhere((v) =>
    v.clientName == visit.clientName &&
        v.phoneNumber == visit.phoneNumber &&
        v.visitTime == visit.visitTime
    );

    if (index >= 0) {
      // Create a new visit with completed status and CURRENT date/time
      final now = DateTime.now();
      final updatedVisit = Visit(
        clientName: visits[index].clientName,
        purpose: visits[index].purpose,
        location: visits[index].location,
        phoneNumber: visits[index].phoneNumber,
        visitTime: now, // Use current date/time for completion
        status: 'completed',
        notes: visits[index].notes,
      );

      setState(() {
        visits[index] = updatedVisit;
      });
      await _saveVisits();
      debugPrint('✅ Visit marked as completed on: ${DateFormat('MMM dd, yyyy HH:mm').format(now)}');
    }
  }

  Future<void> _updateVisitStatus(Visit visit, String newStatus) async {
    final index = visits.indexWhere((v) =>
    v.clientName == visit.clientName &&
        v.phoneNumber == visit.phoneNumber &&
        v.visitTime == visit.visitTime
    );

    if (index >= 0) {
      setState(() {
        visits[index] = visits[index].copyWith(status: newStatus);
      });
      await _saveVisits();
      debugPrint('✅ Visit status updated: ${visit.clientName} -> $newStatus');
    }
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
          return visitDate == today;
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
      MaterialPageRoute(builder: (context) => const ExpenseFormScreen()),
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
            onPressed: () {},
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

          if (result != null && result is Visit) {
            await _addVisit(result);

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
                  icon: Icons.assignment,
                  label: 'Expense Form',
                  onTap: _navigateToExpenseForm,
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling ${visit.phoneNumber}...'),
                        backgroundColor: primaryBlue,
                      ),
                    );
                  },
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                if (isCompleted) {
                  _navigateToClientSummary(visit);
                } else {
                  // Use new completion method
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
                }
              },
              icon: Icon(
                isCompleted ? Icons.visibility : Icons.check,
                size: 16,
              ),
              label: Text(
                isCompleted ? 'View Summary' : 'Mark Completed',
                style: const TextStyle(fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isCompleted ? primaryBlue : Colors.grey[700],
                side: BorderSide(
                  color: isCompleted ? primaryBlue : Colors.grey[400]!,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}