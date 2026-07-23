import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class CheckInHistoryScreen extends StatefulWidget {
  const CheckInHistoryScreen({super.key});

  @override
  State<CheckInHistoryScreen> createState() => _CheckInHistoryScreenState();
}

class _CheckInHistoryScreenState extends State<CheckInHistoryScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color tealGreen = Color(0xFF00897B);

  List<Map<String, dynamic>> _visits = [];
  bool _isLoading = true;
  bool _isCheckingIn = false;
  int? _checkingInVisitId;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadVisits();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVisits() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getVisits();
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _visits = (response['data'] as List).cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  // ── GPS Check-In ──
  Future<void> _performCheckIn(int visitId) async {
    setState(() {
      _isCheckingIn = true;
      _checkingInVisitId = visitId;
    });

    try {
      // 1. Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showSnack('Location permission denied. Please enable it in settings.', Colors.red);
        }
        return;
      }

      // 2. Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Reverse geocode
      String address = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      try {
        final geoUrl = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}',
        );
        final geoResponse = await http.get(geoUrl, headers: {
          'User-Agent': 'PegasosFieldApp/2.0',
        }).timeout(const Duration(seconds: 5));

        if (geoResponse.statusCode == 200) {
          final data = jsonDecode(geoResponse.body);
          final a = data['address'];
          if (a != null) {
            final parts = [
              a['road'],
              a['suburb'] ?? a['neighbourhood'],
              a['city'] ?? a['town'] ?? a['village'],
              a['state'],
            ].where((e) => e != null).toList();
            if (parts.isNotEmpty) address = parts.join(', ');
          }
        }
      } catch (_) {}

      // 4. Send to backend
      final result = await ApiService.checkIn(
        visitId: visitId,
        lat: position.latitude,
        lng: position.longitude,
        address: address,
      );

      if (result['success'] == true) {
        _showSnack('✅ Checked in successfully at $address', tealGreen);
        await _loadVisits();
      } else {
        _showSnack(result['message'] ?? 'Check-in failed', Colors.red);
      }
    } catch (e) {
      _showSnack('Check-in error: ${e.toString().substring(0, 50)}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
          _checkingInVisitId = null;
        });
      }
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Helpers ──
  bool _isCheckedIn(Map<String, dynamic> v) {
    return v['status'] == 'checked_in' || v['checkin_time'] != null;
  }

  String _formatDateTime(String? iso) {
    if (iso == null) return '—';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'checked_in':
        return tealGreen;
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'pending':
        return Colors.orange;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'checked_in':
        return Icons.check_circle;
      case 'completed':
        return Icons.task_alt;
      case 'pending':
        return Icons.schedule;
      case 'missed':
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  // ── Group by date ──
  Map<String, List<Map<String, dynamic>>> _groupByDate() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final v in _visits) {
      final dateStr = v['created_at'] ?? v['checkin_time'] ?? '';
      String dateKey;
      try {
        dateKey = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.parse(dateStr).toLocal());
      } catch (_) {
        dateKey = 'Unknown Date';
      }
      grouped.putIfAbsent(dateKey, () => []).add(v);
    }
    return grouped;
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Check-In History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadVisits,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : _visits.isEmpty
              ? _buildEmptyState()
              : _buildVisitList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _animCtrl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_outlined, size: 60, color: primaryBlue),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Visits Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A202C)),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a visit first, then check in here.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitList() {
    final grouped = _groupByDate();

    return RefreshIndicator(
      onRefresh: _loadVisits,
      color: primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: grouped.length,
        itemBuilder: (_, groupIdx) {
          final dateKey = grouped.keys.elementAt(groupIdx);
          final visits = grouped[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: primaryBlue),
                          const SizedBox(width: 6),
                          Text(
                            dateKey,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${visits.length} visit${visits.length != 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              // Visit cards
              ...visits.map((visit) => _buildVisitCard(visit)),

              if (groupIdx < grouped.length - 1)
                Divider(height: 24, color: Colors.grey.shade200, indent: 20, endIndent: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit) {
    final isChecked = _isCheckedIn(visit);
    final status = visit['status'] ?? 'pending';
    final isThisCheckingIn = _isCheckingIn && _checkingInVisitId == visit['id'];
    final canCheckIn = !isChecked && (status == 'pending' || status == 'assigned');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isChecked ? tealGreen : _statusColor(status),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    visit['title'] ?? visit['client_name'] ?? 'Visit',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(status), size: 12, color: _statusColor(status)),
                      const SizedBox(width: 4),
                      Text(
                        status.toString().replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Client + Executive
            if (visit['client_name'] != null)
              _infoRow(Icons.person_outline, visit['client_name']),
            if (visit['executive_name'] != null)
              _infoRow(Icons.badge_outlined, 'Exec: ${visit['executive_name']}'),

            // Check-in info
            if (isChecked) ...[
              const Divider(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tealGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: tealGreen.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: tealGreen, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'CHECKED IN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: tealGreen,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (visit['checkin_time'] != null)
                      _infoRow(Icons.access_time, _formatDateTime(visit['checkin_time'])),
                    if (visit['checkin_address'] != null)
                      _infoRow(Icons.location_on, visit['checkin_address']),
                    if (visit['checkin_lat'] != null && visit['checkin_lng'] != null)
                      _infoRow(Icons.gps_fixed,
                          'GPS: ${_parseNum(visit['checkin_lat'])}, ${_parseNum(visit['checkin_lng'])}'),
                  ],
                ),
              ),
            ] else if (canCheckIn) ...[
              const SizedBox(height: 12),
              // Check-in button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isThisCheckingIn
                      ? null
                      : () => _showCheckInConfirmation(visit['id']),
                  icon: isThisCheckingIn
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.gps_fixed, size: 18),
                  label: Text(
                    isThisCheckingIn ? 'Capturing Location...' : 'Check In with GPS',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tealGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],

            // Created time
            if (!isChecked) ...[
              const SizedBox(height: 10),
              _infoRow(Icons.access_time_outlined,
                  'Created: ${_formatDateTime(visit['created_at'])}'),
            ],
          ],
        ),
      ),
    );
  }

  String _parseNum(dynamic val) {
    if (val == null) return '0';
    if (val is num) return val.toStringAsFixed(5);
    return double.tryParse(val.toString())?.toStringAsFixed(5) ?? val.toString();
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckInConfirmation(int visitId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tealGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.gps_fixed, color: tealGreen, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Confirm Check-In',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'This will capture your current GPS location and record it as the check-in point for this visit.\n\nMake sure you are at the visit location.',
          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _performCheckIn(visitId);
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Check In Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: tealGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}