import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'expense_form_screen.dart';
import 'package:intl/intl.dart';

class TeamExpensesScreen extends StatefulWidget {
  const TeamExpensesScreen({super.key});

  @override
  State<TeamExpensesScreen> createState() => _TeamExpensesScreenState();
}

class _TeamExpensesScreenState extends State<TeamExpensesScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color lightGray = Color(0xFFF1F5F9);
  
  bool _isLoading = true;
  List<dynamic> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getExpenses(all: true);
    if (response['success'] == true) {
      setState(() {
        _expenses = response['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to load expenses')),
        );
      }
    }
  }

  Future<void> _updateStatus(int expenseId, String newStatus, double amountClaimed) async {
    // If approving, allow manager to override the claimed amount
    double finalAmount = amountClaimed;
    if (newStatus == 'Approved') {
      final controller = TextEditingController(text: amountClaimed.toString());
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Approve Expense'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Final Approved Amount (₹)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                final val = double.tryParse(controller.text);
                if (val != null) {
                  finalAmount = val;
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Approve'),
            ),
          ],
        ),
      );
      if (result != true) return;
    }

    final response = await ApiService.updateExpenseStatus(expenseId, newStatus, finalAmount);
    if (response['success'] == true) {
      _loadExpenses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Failed to update status')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text('Team Expenses Approvals', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadExpenses,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
              ? _buildEmptyState()
              : _buildExpenseList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no team expenses to review.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        final status = expense['status'] ?? 'Pending';
        final date = DateTime.tryParse(expense['created_at']) ?? DateTime.now();
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExpenseFormScreen(expenseId: expense['id']),
                ),
              );
              _loadExpenses();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${expense['title'] ?? 'Claim #${expense['id']}'} - ${expense['user_name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Total Req', expense['total_amount_request']),
                      _buildMetric('In Progress', expense['amount_in_progress']),
                      _buildMetric('Claimed', expense['amount_claimed']),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(date)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      if (status == 'Pending')
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _updateStatus(expense['id'], 'Rejected', 0),
                              child: const Text('Reject', style: TextStyle(color: Colors.red)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () => _updateStatus(
                                expense['id'], 
                                'Approved', 
                                double.parse((expense['amount_in_progress'] ?? 0).toString())
                              ),
                              child: const Text('Approve', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetric(String label, dynamic amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(
          '₹${double.parse((amount ?? 0).toString()).toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
