import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'client_summary_screen.dart';
import '../services/api_service.dart';

/// Screen that shows tasks filtered by a specific status.
/// Navigated to when a dashboard stat card (Total/Completed/Pending/Missed)
/// is tapped on the HomeScreen.
class FilteredTasksScreen extends StatefulWidget {
  final String? filterStatus; // null means 'all', otherwise 'completed', 'pending', 'missed'
  final String filterLabel;  // Display title
  final bool isAdminOrManager;

  const FilteredTasksScreen({
    super.key,
    this.filterStatus,
    required this.filterLabel,
    this.isAdminOrManager = false,
  });

  @override
  State<FilteredTasksScreen> createState() => _FilteredTasksScreenState();
}

class _FilteredTasksScreenState extends State<FilteredTasksScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);

  List<Visit> _visits = [];
  bool _isLoading = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserId();
    await _loadVisits();
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        final userData = jsonDecode(userString);
        _userId = userData['employeeId'] ??
            userData['id']?.toString() ??
            'default';
      } else {
        _userId = 'default';
      }
    } catch (_) {
      _userId = 'default';
    }
  }

  Future<void> _loadVisits() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getTasks(all: widget.isAdminOrManager);
      if (response['success'] == true && response['data'] != null) {
        final List data = response['data'];
        List<Visit> all = data.map((e) => Visit.fromJson(e as Map<String, dynamic>)).toList();

        // Filter based on status
        if (widget.filterStatus != null && widget.filterStatus != 'all') {
          all = all.where((v) => v.status == widget.filterStatus).toList();
        }

        all.sort((a, b) => b.visitTime.compareTo(a.visitTime));
        if (mounted) setState(() => _visits = all);
      }
    } catch (e) {
      debugPrint('❌ Error loading visits: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateVisitStatus(int index, String newStatus) async {
    if (index < 0 || index >= _visits.length) return;
    final visit = _visits[index];
    if (visit.id == null) return;

    setState(() => _isLoading = true);
    try {
      final response = visit.isTask
          ? await ApiService.updateTaskStatus(visit.id!, newStatus)
          : await ApiService.updateVisitStatus(visit.id!, newStatus);
          
      if (response['success'] == true) {
        await _loadVisits();
      }
    } catch (e) {
      debugPrint('❌ Error updating status: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteVisit(int index) async {
    if (index < 0 || index >= _visits.length) return;
    final visit = _visits[index];
    if (visit.id == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.deleteTask(visit.id!);
      if (response['success'] == true) {
        await _loadVisits();
      }
    } catch (e) {
      debugPrint('❌ Error deleting task: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return primaryBlue;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'COMPLETED';
      case 'missed':
        return 'MISSED';
      case 'pending':
        return 'PENDING';
      default:
        return status.toUpperCase();
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'missed':
        return Icons.cancel_outlined;
      case 'pending':
        return Icons.schedule_outlined;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          '${widget.filterLabel} Tasks',
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_visits.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : _visits.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadVisits,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _visits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => _buildCard(_visits[index], index),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_statusIcon(widget.filterStatus ?? 'all'),
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No ${widget.filterLabel} Tasks',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no tasks with this status',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Visit visit, int index) {
    final statusColor = _statusColor(visit.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
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
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(visit.clientName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A))),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(visit.status),
                        size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(_statusLabel(visit.status),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(visit.purpose,
              style:
                  const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const SizedBox(height: 8),
          // Location + time
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(visit.location,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600])),
              ),
              Text(
                DateFormat('dd MMM, HH:mm').format(visit.visitTime),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          if (visit.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_outlined,
                      size: 14, color: primaryBlue.withOpacity(0.7)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(visit.notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[700])),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              // Call
              _actionBtn(Icons.phone, 'Call', primaryBlue,
                  () => _makeCall(visit.phoneNumber)),
              const SizedBox(width: 8),
              // Mail It
              _actionBtn(Icons.email_outlined, 'Mail It', Colors.teal, () {
                final subject =
                    Uri.encodeComponent('Visit Update: ${visit.clientName}');
                final body = Uri.encodeComponent(
                    'Client: ${visit.clientName}\n'
                    'Title: ${visit.purpose}\n'
                    'Location: ${visit.location}\n'
                    'Date: ${DateFormat('dd MMMM yyyy, HH:mm').format(visit.visitTime)}\n'
                    'Status: ${_statusLabel(visit.status)}\n'
                    'Notes: ${visit.notes}');
                _sendEmail('?subject=$subject&body=$body');
              }),
              const Spacer(),
              // Status actions
              if (visit.status == 'pending') ...[
                _smallActionBtn('Complete', Colors.green,
                    () => _updateVisitStatus(index, 'completed')),
                const SizedBox(width: 4),
              ] else ...[
                _smallActionBtn('Pending', Colors.orange,
                    () => _updateVisitStatus(index, 'pending')),
                const SizedBox(width: 4),
              ],
              _smallActionBtn('Delete', Colors.red, () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text('Delete Visit'),
                    content: Text(
                        'Delete visit with ${visit.clientName}?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _deleteVisit(index);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _smallActionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}
