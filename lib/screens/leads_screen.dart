import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';
import '../utils/download_helper.dart';

// ── Lead Model (aligned with backend 6-stage pipeline) ──
class Lead {
  final int? id; // Backend ID
  final String name;
  final String phone;
  final String email;
  final String company;
  final String source;
  String status; // new, contacted, qualified, proposal, won, lost
  String? classification; // hot, warm, cold
  final String notes;
  final DateTime createdAt;

  Lead({
    this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.company = '',
    this.source = '',
    this.status = 'new',
    this.classification,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'client_name': name,
        'client_phone': phone,
        'client_email': email,
        'company': company,
        'source': source,
        'status': status,
        'classification': classification,
        'notes': notes,
      };

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        id: json['id'],
        // Support both backend field names and local names
        name: json['client_name'] ?? json['name'] ?? '',
        phone: json['client_phone'] ?? json['phone'] ?? '',
        email: json['client_email'] ?? json['email'] ?? '',
        company: json['company'] ?? '',
        source: json['source'] ?? '',
        status: json['status'] ?? 'new',
        classification: json['classification'],
        notes: json['notes'] ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now(),
      );
}

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);

  List<Lead> _leads = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String _selectedClassificationFilter = 'All';
  String _userId = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _loadUserId();
    await _loadLeads();
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

  Future<void> _loadLeads() async {
    setState(() => _isLoading = true);
    try {
      // Try backend first
      final response = await ApiService.getLeads();
      if (response['success'] == true && response['data'] != null) {
        final List data = response['data'];
        setState(() {
          _leads = data
              .map((e) => Lead.fromJson(e as Map<String, dynamic>))
              .toList();
        });
        await _saveLeadsLocal(); // Cache for reliability
      } else {
        // Fallback: load from local storage
        await _loadLeadsLocal();
      }
    } catch (_) {
      await _loadLeadsLocal();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadLeadsLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leadsString = prefs.getString('leads_$_userId');
      if (leadsString != null) {
        final List<dynamic> leadsJson = jsonDecode(leadsString);
        _leads = leadsJson
            .map((json) => Lead.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _leads = [];
    }
  }

  Future<void> _saveLeadsLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leadsJson = _leads.map((l) => l.toJson()).toList();
      await prefs.setString('leads_$_userId', jsonEncode(leadsJson));
    } catch (_) {}
  }

  // All valid pipeline statuses
  static const List<String> _allStatuses = ['new', 'contacted', 'qualified', 'proposal', 'won', 'lost'];
  static const List<String> _allClassifications = ['hot', 'warm', 'cold'];

  List<Lead> _getFilteredLeads() {
    List<Lead> filtered = _leads;
    
    if (_selectedFilter != 'All') {
      final filterStatus = _selectedFilter.toLowerCase();
      filtered = filtered.where((l) => l.status == filterStatus).toList();
    }
    
    if (_selectedClassificationFilter != 'All') {
      final filterClass = _selectedClassificationFilter.toLowerCase();
      filtered = filtered.where((l) => l.classification == filterClass).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((l) =>
              l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              l.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              l.phone.contains(_searchQuery))
          .toList();
    }
    return filtered;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new':
        return const Color(0xFF3B82F6);
      case 'contacted':
        return const Color(0xFFF59E0B);
      case 'qualified':
        return const Color(0xFF10B981);
      case 'proposal':
        return const Color(0xFFF97316);
      case 'won':
        return const Color(0xFF059669);
      case 'lost':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'new':
        return Icons.fiber_new;
      case 'contacted':
        return Icons.phone_callback;
      case 'qualified':
        return Icons.verified;
      case 'proposal':
        return Icons.description_outlined;
      case 'won':
        return Icons.emoji_events;
      case 'lost':
        return Icons.cancel_outlined;
      default:
        return Icons.circle;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'new':
        return 'NEW';
      case 'contacted':
        return 'CONTACTED';
      case 'qualified':
        return 'QUALIFIED';
      case 'proposal':
        return 'PROPOSAL';
      case 'won':
        return 'WON';
      case 'lost':
        return 'LOST';
      default:
        return status.toUpperCase();
    }
  }

  Color _classificationColor(String? classification) {
    switch (classification) {
      case 'hot': return Colors.red;
      case 'warm': return Colors.orange;
      case 'cold': return Colors.blue;
      default: return Colors.grey;
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

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateLeadStatus(int index, String newStatus) async {
    final lead = _leads[index];
    if (lead.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot update lead without ID'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.updateLeadStatus(lead.id!, newStatus);
      if (response['success'] == true) {
        await _loadLeads();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lead status updated to ${newStatus.toUpperCase()}'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update lead'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLead(int index) async {
    final lead = _leads[index];
    if (lead.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete lead without ID'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.deleteLead(lead.id!);
      if (response['success'] == true) {
        await _loadLeads();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lead deleted successfully'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to delete lead'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddLeadDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final sourceCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedStatus = 'new';
    String? selectedClassification;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.person_add, color: primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Add New Lead',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A202C))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Full Name *', Icons.person_outline),
                const SizedBox(height: 12),
                _dialogField(phoneCtrl, 'Phone *', Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _dialogField(emailCtrl, 'Email', Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _dialogField(
                    companyCtrl, 'Company', Icons.business_outlined),
                const SizedBox(height: 12),
                _dialogField(sourceCtrl, 'Source', Icons.source_outlined),
                const SizedBox(height: 16),
                // Status selector (6-stage pipeline)
                const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allStatuses.map((s) {
                    final isSelected = selectedStatus == s;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedStatus = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _statusColor(s).withOpacity(0.15)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? _statusColor(s)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon(s),
                                size: 12, color: _statusColor(s)),
                            const SizedBox(width: 4),
                            Text(
                              _statusLabel(s),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(s),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Classification (Status)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedClassification,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    isDense: true,
                  ),
                  hint: const Text('Select classification'),
                  items: _allClassifications.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.toUpperCase()),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedClassification = v),
                ),
                const SizedBox(height: 12),
                _dialogField(notesCtrl, 'Notes', Icons.notes_outlined,
                    maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty ||
                    phoneCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name and Phone are required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final leadData = {
                  'client_name': nameCtrl.text.trim(),
                  'client_phone': phoneCtrl.text.trim(),
                  'client_email': emailCtrl.text.trim(),
                  'company': companyCtrl.text.trim(),
                  'source': sourceCtrl.text.trim(),
                  'status': selectedStatus,
                  'classification': selectedClassification,
                  'notes': notesCtrl.text.trim(),
                };

                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                
                try {
                  final response = await ApiService.createLead(leadData);
                  if (response['success'] == true) {
                    await _loadLeads();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lead added successfully'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['message'] ?? 'Failed to add lead'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Network error: $e'), backgroundColor: Colors.red),
                  );
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add Lead',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(
      TextEditingController ctrl, String hint, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredLeads();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 24),
            onPressed: () => _logout(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadLeads,
          ),
        ],
        title: const Text('Leads',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: primaryBlue,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search leads by name, company, phone...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey[500], size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: Colors.grey[500], size: 20),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),

          // Filter chips (6-stage pipeline)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ...['All', ..._allStatuses.map((s) => s[0].toUpperCase() + s.substring(1))].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  final filterKey = filter.toLowerCase();
                  final chipColor = filter == 'All' ? primaryBlue : _statusColor(filterKey);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? chipColor.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? chipColor : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (filter != 'All') ...[
                            Icon(_statusIcon(filterKey),
                                size: 13, color: chipColor),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? chipColor : Colors.grey[600],
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  }),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    initialValue: _selectedClassificationFilter,
                    onSelected: (String value) {
                      setState(() {
                        _selectedClassificationFilter = value;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return ['All', 'Hot', 'Warm', 'Cold'].map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Row(
                            children: [
                              if (choice != 'All')
                                Icon(Icons.circle, size: 12, color: _classificationColor(choice.toLowerCase())),
                              if (choice != 'All') const SizedBox(width: 8),
                              Text(choice),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: _selectedClassificationFilter != 'All' ? _classificationColor(_selectedClassificationFilter.toLowerCase()).withOpacity(0.15) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _selectedClassificationFilter != 'All' ? _classificationColor(_selectedClassificationFilter.toLowerCase()) : Colors.transparent, width: _selectedClassificationFilter != 'All' ? 2 : 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.list, size: 13, color: _selectedClassificationFilter != 'All' ? _classificationColor(_selectedClassificationFilter.toLowerCase()) : Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text(
                            _selectedClassificationFilter == 'All' ? 'STATUS' : _selectedClassificationFilter.toUpperCase(),
                            style: TextStyle(
                              color: _selectedClassificationFilter != 'All' ? _classificationColor(_selectedClassificationFilter.toLowerCase()) : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, color: _selectedClassificationFilter != 'All' ? _classificationColor(_selectedClassificationFilter.toLowerCase()) : Colors.grey[700], size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Count and Status Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} Lead${filtered.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lead list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryBlue))
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadLeads,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final leadIndex = _leads.indexOf(filtered[index]);
                            return _buildLeadCard(filtered[index], leadIndex);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: _showAddLeadDialog,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No Leads Found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search'
                : 'Tap + to add your first lead',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(Lead lead, int index) {
    final statusColor = _statusColor(lead.status);

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
          // Name + status
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryBlue.withOpacity(0.1),
                child: Text(
                  lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lead.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A))),
                    if (lead.company.isNotEmpty)
                      Text(lead.company,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              // Status and Classification dropdowns
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (newStatus) => _updateLeadStatus(index, newStatus),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (_) => _allStatuses
                        .map((s) => _statusMenuItem(s))
                        .toList(),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(lead.status),
                              size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            _statusLabel(lead.status),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_drop_down,
                              size: 14, color: statusColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PopupMenuButton<String>(
                    onSelected: (newClass) async {
                      if (lead.id == null) return;
                      setState(() => _isLoading = true);
                      final res = await ApiService.updateLeadClassification(lead.id!, newClass);
                      if (res['success'] == true) {
                        setState(() { lead.classification = newClass; });
                      }
                      setState(() => _isLoading = false);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (_) => _allClassifications
                        .map((c) => PopupMenuItem(
                              value: c,
                              child: Row(
                                children: [
                                  Icon(Icons.circle, size: 10, color: _classificationColor(c)),
                                  const SizedBox(width: 8),
                                  Text(c.toUpperCase(), style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ))
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: lead.classification != null ? _classificationColor(lead.classification).withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.list, size: 12, color: lead.classification != null ? _classificationColor(lead.classification) : Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            (lead.classification ?? 'Status').toUpperCase(),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: lead.classification != null ? _classificationColor(lead.classification) : Colors.orange),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_drop_down,
                              size: 14, color: lead.classification != null ? _classificationColor(lead.classification) : Colors.orange),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Phone + source
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(lead.phone,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              if (lead.source.isNotEmpty) ...[
                const SizedBox(width: 16),
                Icon(Icons.source_outlined,
                    size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(lead.source,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ],
          ),
          if (lead.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(lead.notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
          const SizedBox(height: 4),
          Text(
            DateFormat('dd MMM yyyy').format(lead.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              _actionButton(Icons.phone, 'Call', primaryBlue,
                  () => _makeCall(lead.phone)),
              const SizedBox(width: 8),
              if (lead.email.isNotEmpty) ...[
                _actionButton(Icons.email_outlined, 'Email', Colors.teal,
                    () => _sendEmail(lead.email)),
                const SizedBox(width: 8),
              ],
              if (['proposal', 'won', 'lost'].contains(lead.status)) ...[
                _actionButton(Icons.file_copy_outlined, 'Proposals', Colors.orange,
                    () => _showProposalsDialog(lead)),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Colors.red[400], size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showDeleteDialog(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  PopupMenuItem<String> _statusMenuItem(String status) {
    return PopupMenuItem<String>(
      value: status,
      child: Row(
        children: [
          Icon(_statusIcon(status), size: 16, color: _statusColor(status)),
          const SizedBox(width: 8),
          Text(_statusLabel(status),
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: _statusColor(status))),
        ],
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Lead'),
        content: Text(
            'Are you sure you want to delete ${_leads[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteLead(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProposalsDialog(Lead lead) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Proposals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            IconButton(
              icon: const Icon(Icons.upload_file, color: primaryBlue),
              onPressed: () => _uploadProposal(lead.id!),
              tooltip: 'Upload Proposal',
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<Map<String, dynamic>>(
            future: ApiService.getLeadProposals(lead.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!['success'] != true) {
                return const Center(child: Text('Failed to load proposals'));
              }
              
              final List proposals = snapshot.data!['data'] ?? [];
              if (proposals.isEmpty) {
                return const Center(child: Text('No proposals uploaded yet.'));
              }

              return ListView.separated(
                shrinkWrap: true,
                itemCount: proposals.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final p = proposals[index];
                  return ListTile(
                    leading: const Icon(Icons.description, color: Colors.orange),
                    title: Text(p['original_filename'] ?? 'Document', maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('Status: ${p['status']}\nDate: ${DateFormat('dd MMM yyyy').format(DateTime.parse(p['created_at']))}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value: ['pending', 'won', 'lost'].contains(p['status']) ? p['status'] : 'pending',
                          underline: const SizedBox(),
                          style: const TextStyle(fontSize: 12, color: primaryBlue, fontWeight: FontWeight.bold),
                          items: ['pending', 'won', 'lost'].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) async {
                            if (val == null || val == p['status']) return;
                            setState(() => _isLoading = true);
                            await ApiService.updateProposalStatus(p['id'], val);
                            setState(() => _isLoading = false);
                            Navigator.pop(ctx);
                            _showProposalsDialog(lead); // Refresh dialog
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.download, color: primaryBlue),
                          onPressed: () => _downloadProposal(p['id'], p['original_filename'] ?? 'proposal.pdf'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadProposal(int leadId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() => _isLoading = true);
        final response = await ApiService.uploadLeadProposal(
            leadId, result.files.single.bytes!, result.files.single.name);
        
        setState(() => _isLoading = false);
        
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proposal uploaded successfully'), backgroundColor: Colors.green));
          Navigator.pop(context); // Close and reopen to refresh
          _showProposalsDialog(_leads.firstWhere((l) => l.id == leadId));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? 'Upload failed'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _downloadProposal(int proposalId, String filename) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading...')));
      final response = await ApiService.downloadProposal(proposalId);
      
      if (response.statusCode == 200) {
        await saveDownloadedFile(response.bodyBytes, filename);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved $filename successfully!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to download file'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }
}
