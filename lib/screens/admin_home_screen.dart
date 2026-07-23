import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/download_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../services/notification_service.dart';
import 'dart:async';
import 'notifications_screen.dart';
import 'team_expenses_screen.dart';
import 'filtered_tasks_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);

  int _currentIndex = 0;
  String _adminName = '';
  bool _isLoading = true;

  // Dashboard metrics
  int _total = 0;
  int _completed = 0;
  int _pending = 0;
  int _missed = 0;

  // Advanced Stats
  List<dynamic> _performance = [];
  List<dynamic> _recentMissed = [];
  List<dynamic> _leadsStats = [];
  List<dynamic> _visitActivity = [];
  List<dynamic> _tracking = [];

  // Executives list
  List<dynamic> _executives = [];
  List<dynamic> _managers = [];
  List<dynamic> _allTasks = [];
  int _unreadCount = 0;
  String? _selectedExecutiveFilter;

  // Notification polling subscriptions
  StreamSubscription<int>? _unreadSub;
  StreamSubscription<String>? _newNotifSub;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupNotificationPolling();
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    _newNotifSub?.cancel();
    super.dispose();
  }

  void _setupNotificationPolling() {
    final notifService = NotificationService();
    // Start polling in case it hasn't been started (though home screen might have, it's safe to call again)
    notifService.startPolling();

    _unreadSub = notifService.unreadCountStream.listen((count) {
      if (mounted) {
        setState(() => _unreadCount = count);
      }
    });

    _newNotifSub = notifService.newNotificationStream.listen((message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: primaryBlue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ).then((_) {
                  NotificationService().pollNow();
                  _loadData();
                });
              },
            ),
          ),
        );
      }
    });
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    
    // Parallelize calls for high reliability and speed
    await Future.wait([
      _loadAdminInfo(),
      _loadMetrics(),
      _loadAdminStats(),
      _loadExecutives(),
      _loadManagers(),
      _loadAllTasks(),
      _loadTracking(),
      _loadNotifications(),
    ]);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      final userData = jsonDecode(userString);
      if (mounted) setState(() => _adminName = userData['name']?.split(' ')[0] ?? 'Admin');
    }
  }

  Future<void> _loadMetrics() async {
    try {
      final response = await ApiService.getDashboardMetrics();
      if (response['success'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _total = data['total'] ?? 0;
          _completed = data['completed'] ?? 0;
          _pending = data['pending'] ?? 0;
          _missed = data['missed'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading metrics: $e');
    }
  }

  Future<void> _loadAdminStats() async {
    try {
      final response = await ApiService.getAdminStats();
      if (response['success'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _performance = data['performance'] ?? [];
          _recentMissed = data['recentMissed'] ?? [];
          _leadsStats = data['leadsStats'] ?? [];
          _visitActivity = data['visitActivity'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error loading admin stats: $e');
    }
  }

  Future<void> _loadExecutives() async {
    try {
      final response = await ApiService.getExecutives();
      if (response['success'] == true && mounted) {
        final List<dynamic> execs = response['data'] ?? [];
        // Merge with performance data (robustly)
        for (var i = 0; i < execs.length; i++) {
          final perf = _performance.any((p) => p['id'] == execs[i]['id'])
              ? _performance.firstWhere((p) => p['id'] == execs[i]['id'])
              : null;
          if (perf != null) {
            execs[i]['success_rate'] = perf['success_rate'];
            execs[i]['completed_tasks'] = perf['completed_tasks'];
            execs[i]['total_tasks'] = perf['total_tasks'];
          }
        }
        setState(() => _executives = execs);
      }
    } catch (e) {
      debugPrint('Error loading executives: $e');
    }
  }

  Future<void> _loadManagers() async {
    try {
      final response = await ApiService.getManagers();
      if (response['success'] == true && mounted) {
        setState(() => _managers = response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading managers: $e');
    }
  }

  Future<void> _loadAllTasks() async {
    try {
      final response = await ApiService.getTasks(all: true);
      if (response['success'] == true && mounted) {
        setState(() => _allTasks = response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading all tasks: $e');
    }
  }

  Future<void> _loadTracking() async {
    try {
      final response = await ApiService.getExecutiveTracking();
      if (response['success'] == true && mounted) {
        setState(() => _tracking = response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading tracking: $e');
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final response = await ApiService.getNotifications();
      if (response['success'] == true && mounted) {
        setState(() => _unreadCount = response['unreadCount'] ?? 0);
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: primaryBlue,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Panel',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('Welcome, $_adminName!',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsScreen()),
                  );
                  _loadNotifications();
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text('$_unreadCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9)),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          _buildManagersTab(),
          _buildExecutivesTab(),
          _buildTasksTab(),
          _buildProfileTab(),
        ],
      ),
      // Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey.shade400,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts_outlined),
              activeIcon: Icon(Icons.manage_accounts),
              label: 'Managers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Executives'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Tasks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }


  // ── Tab: Dashboard ──
  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetricCard('Total', _total, Icons.assessment_outlined, primaryBlue, null, 'Total Tasks'),
                const SizedBox(width: 10),
                _buildMetricCard('Completed', _completed, Icons.check_circle_outline, Colors.green, 'completed', 'Completed Tasks'),
                const SizedBox(width: 10),
                _buildMetricCard('Pending', _pending, Icons.schedule_outlined, Colors.orange, 'pending', 'Pending Tasks'),
                const SizedBox(width: 10),
                _buildMetricCard('Missed', _missed, Icons.cancel_outlined, Colors.red, 'missed', 'Missed Tasks'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TeamExpensesScreen()),
                      );
                    },
                    icon: const Icon(Icons.receipt_long, color: Colors.white),
                    label: const Text('Expense Approvals', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showExportDialog(),
                    icon: const Icon(Icons.download, color: primaryBlue),
                    label: const Text('Export Data', style: TextStyle(color: primaryBlue)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: primaryBlue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Team Performance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (_performance.isEmpty)
              _buildEmptyCard('No performance data available')
            else
              Container(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _performance.length,
                  itemBuilder: (context, index) => _buildPerformanceCard(_performance[index]),
                ),
              ),
            const SizedBox(height: 24),
            const Text('Recent Missed Tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.red)),
            const SizedBox(height: 12),
            if (_recentMissed.isEmpty)
              _buildEmptyCard('No recent missed tasks')
            else
              ..._recentMissed.map((task) => _buildMissedTaskCard(task)),
            const SizedBox(height: 24),
            const Text('All Tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (_allTasks.isEmpty)
              _buildEmptyCard('No tasks found')
            else
              ..._allTasks.take(10).map((task) => _buildTaskCard(task)),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExportOption('Visits', 'visits', Icons.location_on),
            _buildExportOption('Tasks', 'tasks', Icons.assignment),
            _buildExportOption('Leads', 'leads', Icons.group),
            _buildExportOption('Expenses', 'expenses', Icons.receipt_long),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildExportOption(String title, String entity, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: primaryBlue),
      title: Text(title),
      trailing: const Icon(Icons.download, size: 20),
      onTap: () async {
        Navigator.pop(context); // Close dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preparing $title export...')),
        );

        final bytes = await ApiService.downloadExport(entity);
        if (bytes != null) {
          await saveDownloadedFile(bytes, '${entity}_export.csv');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title exported successfully!'), backgroundColor: Colors.green),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to export data'), backgroundColor: Colors.red),
            );
          }
        }
      },
    );
  }

  // ── Tab: Managers ──
  Widget _buildManagersTab() {
    return RefreshIndicator(
      onRefresh: _loadManagers,
      child: _managers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.manage_accounts_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No managers found',
                      style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _managers.length,
              itemBuilder: (context, index) => _buildManagerCard(_managers[index]),
            ),
    );
  }

  // ── Tab: Executives ──
  Widget _buildExecutivesTab() {
    return RefreshIndicator(
      onRefresh: _loadExecutives,
      child: _executives.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No executives found',
                      style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _executives.length,
              itemBuilder: (context, index) => _buildExecutiveCard(_executives[index]),
            ),
    );
  }

  // ── Tab: Tasks ──
  Widget _buildTasksTab() {
    // Filter tasks by selected executive
    final filteredTasks = _selectedExecutiveFilter == null
        ? _allTasks
        : _allTasks.where((t) => t['assigned_to']?.toString() == _selectedExecutiveFilter).toList();

    return RefreshIndicator(
      onRefresh: _loadAllTasks,
      child: Column(
        children: [
          // Executive filter dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 18, color: Color(0xFF0F3A68)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedExecutiveFilter,
                      isExpanded: true,
                      hint: const Text('All Executives', style: TextStyle(fontSize: 14)),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Executives'),
                        ),
                        ..._executives.map((exec) => DropdownMenuItem<String?>(
                              value: exec['id']?.toString(),
                              child: Text('${exec['name'] ?? 'Unknown'} (${exec['employee_id'] ?? ''})'),
                            )),
                      ],
                      onChanged: (val) => setState(() => _selectedExecutiveFilter = val),
                    ),
                  ),
                ),
                if (_selectedExecutiveFilter != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                    onPressed: () => setState(() => _selectedExecutiveFilter = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Tasks list
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedExecutiveFilter != null
                              ? 'No tasks for this executive'
                              : 'No tasks found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) => _buildTaskCard(filteredTasks[index]),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Tab: Profile ──
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: primaryBlue.withOpacity(0.1),
            child: Text(
              (_adminName.isNotEmpty ? _adminName[0] : 'A').toUpperCase(),
              style: const TextStyle(
                  color: primaryBlue, fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(_adminName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          Text('Administrator',
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('System Stats',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.people_outline, size: 18, color: primaryBlue),
                  const SizedBox(width: 12),
                  Text('${_performance.length} Field Executives',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.assignment_outlined, size: 18, color: primaryBlue),
                  const SizedBox(width: 12),
                  Text('${_allTasks.length} Total Active Tasks',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.warning_amber_outlined, size: 18, color: Colors.red),
                  const SizedBox(width: 12),
                  Text('${_recentMissed.length} Recent Missed Tasks',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, int count, IconData icon, Color color, [String? filterStatus, String? filterLabel]) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilteredTasksScreen(
                filterStatus: filterStatus,
                filterLabel: filterLabel ?? title,
                isAdminOrManager: true,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(title,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('$count',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagerCard(Map<String, dynamic> manager) {
    return GestureDetector(
      onTap: () => _showManagerExecutives(manager),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
          CircleAvatar(
            backgroundColor: primaryBlue.withOpacity(0.1),
            child: Text(
              (manager['name'] ?? 'M')[0].toUpperCase(),
              style: const TextStyle(
                  color: primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(manager['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text('${manager['employee_id']} • ${manager['phone'] ?? 'No phone'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text('${manager['fe_count'] ?? 0} Field Executive(s)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryBlue)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildExecutiveCard(Map<String, dynamic> exec) {
    return GestureDetector(
      onTap: () => _showExecutiveTasks(exec),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
          CircleAvatar(
            backgroundColor: primaryBlue.withOpacity(0.1),
            child: Text(
              (exec['name'] ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                  color: primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exec['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text('${exec['employee_id']} • ${exec['zone'] ?? 'No zone'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                if (exec['success_rate'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Builder(
                      builder: (context) {
                        final rate = double.tryParse(exec['success_rate'].toString()) ?? 0;
                        return Text('Success Rate: ${rate.toInt()}% (${exec['completed_tasks']}/${exec['total_tasks']})',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: rate > 70 ? Colors.green : Colors.orange));
                      }
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Active',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(exec['manager_name'] != null ? 'Manager: ${exec['manager_name']}' : 'No Manager Assigned',
              style: TextStyle(fontSize: 12, color: exec['manager_name'] != null ? primaryBlue : Colors.grey[600], fontWeight: exec['manager_name'] != null ? FontWeight.w600 : FontWeight.normal)),
          InkWell(
            onTap: () => _showAssignManagerDialog(exec),
            child: Text('Change', style: TextStyle(fontSize: 12, color: primaryBlue, decoration: TextDecoration.underline)),
          )
        ],
      )
      ]
      ),
      ),
    );
  }

  void _showAssignManagerDialog(Map<String, dynamic> exec) {
    int? selectedManagerId = exec['manager_id'];
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Assign Manager'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select a manager for ${exec['name']}'),
                  const SizedBox(height: 16),
                  DropdownButton<int?>(
                    isExpanded: true,
                    value: selectedManagerId,
                    hint: const Text('No Manager'),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('None (Remove Manager)')),
                      ..._managers.map((m) => DropdownMenuItem<int?>(
                        value: m['id'],
                        child: Text('${m['name']} (${m['employee_id']})')
                      ))
                    ],
                    onChanged: (val) => setState(() => selectedManagerId = val),
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final res = await ApiService.assignManager(exec['id'], selectedManagerId);
                    if (res['success'] == true) {
                      _loadExecutives();
                      _loadManagers();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manager assigned successfully')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Failed to assign manager')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
                  child: const Text('Save'),
                )
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    Color statusColor;
    switch (task['status']) {
      case 'completed': statusColor = Colors.green; break;
      case 'missed': statusColor = Colors.red; break;
      case 'in_progress': statusColor = Colors.blue; break;
      default: statusColor = Colors.orange;
    }

    // Format scheduled time safely
    String scheduledStr = '';
    try {
      if (task['scheduled_time'] != null) {
        final dt = DateTime.parse(task['scheduled_time'].toString()).toLocal();
        scheduledStr = DateFormat('dd MMM, hh:mm a').format(dt);
      }
    } catch (_) {}

    return GestureDetector(
      onTap: () => _showEditTaskDialog(task),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(task['executive_name'] ?? 'Unassigned',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                if (task['client_name'] != null && task['client_name'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.business_outlined, size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(task['client_name'].toString(),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                if (scheduledStr.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.schedule_outlined, size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(scheduledStr,
                            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                if (task['location'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(task['location'],
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              (task['status'] ?? '').toUpperCase(),
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[500], fontSize: 14)),
    );
  }

  Widget _buildPerformanceCard(Map<String, dynamic> perf) {
    final double successRate = double.tryParse(perf['success_rate']?.toString() ?? '0') ?? 0.0;
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: successRate / 100,
                backgroundColor: Colors.grey[100],
                color: successRate > 70 ? Colors.green : (successRate > 40 ? Colors.orange : Colors.red),
                strokeWidth: 6,
              ),
              Text('${successRate.toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(perf['name'] ?? '', 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('${perf['completed_tasks']}/${perf['total_tasks']} Tasks', 
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMissedTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: Colors.red, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(task['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              Text(_safeFormatTime(task['updated_at']), 
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 4),
          Text('Executive: ${task['executive_name'] ?? 'Unknown'}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 2),
          Text('Client: ${task['client_name'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showManagerExecutives(Map<String, dynamic> manager) {
    final managerId = manager['id'];
    final execs = _executives.where((e) => e['manager_id'] == managerId).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Executives under ${manager['name']}',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: execs.isEmpty 
                      ? _buildEmptyCard('No field executives assigned')
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.all(16),
                          itemCount: execs.length,
                          itemBuilder: (context, index) => _buildExecutiveCard(execs[index]),
                        ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _showExecutiveTasks(Map<String, dynamic> exec) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Text(
                            (exec['name'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exec['name'] ?? 'Executive',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(exec['employee_id'] ?? '',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: ApiService.getExecutiveTasks(exec['id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || snapshot.data?['success'] != true) {
                          return Center(child: Text('Failed to load tasks', style: TextStyle(color: Colors.grey[600])));
                        }
                        final tasks = snapshot.data?['data'] as List<dynamic>? ?? [];
                        if (tasks.isEmpty) {
                          return _buildEmptyCard('No tasks assigned');
                        }
                        return ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.all(16),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    String currentStatus = task['status'] ?? 'pending';
    final notesController = TextEditingController(text: task['notes'] ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Task: ${task['title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text('Status'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: currentStatus,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'missed', child: Text('Missed')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => currentStatus = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Notes'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Admin notes...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setState(() => isSaving = true);
                          final res = await ApiService.adminUpdateTask(task['id'], {
                            'status': currentStatus,
                            'notes': notesController.text,
                          });
                          setState(() => isSaving = false);
                          if (res['success'] == true) {
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Task updated successfully')));
                              _loadAllTasks(); // Refresh tasks list
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(res['message'] ?? 'Failed to update')));
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  String _safeFormatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      // Try parsing as ISO
      return DateFormat('HH:mm').format(DateTime.parse(dateStr));
    } catch (_) {
      try {
        // Try parsing common MySQL format
        return DateFormat('HH:mm').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateStr));
      } catch (e) {
        return '';
      }
    }
  }
}
