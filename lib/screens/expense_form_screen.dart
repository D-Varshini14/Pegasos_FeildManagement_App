import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class ExpenseFormScreen extends StatefulWidget {
  final int expenseId;

  const ExpenseFormScreen({super.key, required this.expenseId});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color lightGray = Color(0xFFF1F5F9);
  
  bool _isLoading = true;
  Map<String, dynamic>? _expenseData;
  List<dynamic> _forms = [];

  @override
  void initState() {
    super.initState();
    _loadExpenseData();
  }

  Future<void> _loadExpenseData() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getExpense(widget.expenseId);
    if (response['success'] == true) {
      setState(() {
        _expenseData = response['data'];
        _forms = _expenseData!['forms'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to load expense details')),
        );
      }
    }
  }

  Future<void> _deleteForm(int formId) async {
    final response = await ApiService.deleteExpenseForm(formId);
    if (response['success'] == true) {
      _loadExpenseData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Failed to delete')),
      );
    }
  }

  Future<void> _showAddFormModal() async {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final descController = TextEditingController();
    List<Map<String, dynamic>> attachments = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add Expense Receipt', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: ['Food', 'Travel', 'Accommodation', 'Supplies', 'Other']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) categoryController.text = val;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    // File Upload Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Attach File / Receipt'),
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          withData: true, // IMPORTANT FOR FLUTTER WEB
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'pdf', 'png'],
                        );

                        if (result != null && result.files.single.bytes != null) {
                          setModalState(() {
                            attachments.add({
                              'name': result.files.single.name,
                              'bytes': result.files.single.bytes,
                            });
                          });
                        }
                      },
                    ),

                    if (attachments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('${attachments.length} file(s) selected: ${attachments.map((e) => e['name']).join(', ')}'),
                      ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                        onPressed: () async {
                          if (categoryController.text.isEmpty || amountController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category and Amount required')));
                            return;
                          }

                          Navigator.pop(context); // Close modal
                          
                          // Show loading dialog
                          showDialog(
                            context: this.context,
                            barrierDismissible: false,
                            builder: (c) => const Center(child: CircularProgressIndicator()),
                          );

                          final res = await ApiService.addExpenseForm(
                            expenseId: widget.expenseId,
                            category: categoryController.text,
                            amount: double.parse(amountController.text),
                            description: descController.text,
                            attachments: attachments,
                          );

                          Navigator.pop(this.context); // Close loading

                          if (res['success'] == true) {
                            _loadExpenseData();
                          } else {
                            ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Error')));
                          }
                        },
                        child: const Text('Submit Receipt', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Text(
          _expenseData != null && _expenseData!['title'] != null 
            ? '${_expenseData!['title']} Details' 
            : 'Expense #${widget.expenseId} Details', 
          style: const TextStyle(color: Colors.white)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expenseData == null
              ? const Center(child: Text('Failed to load.'))
              : Column(
                  children: [
                    _buildSummaryCard(),
                    Expanded(
                      child: _forms.isEmpty
                          ? const Center(child: Text('No receipts added yet. Click + to add.'))
                          : _buildFormsList(),
                    ),
                  ],
                ),
      floatingActionButton: _expenseData != null && _expenseData!['status'] == 'Pending'
          ? FloatingActionButton(
              backgroundColor: primaryBlue,
              onPressed: _showAddFormModal,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null, // Don't allow adding if approved/rejected
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  _expenseData!['status'] ?? 'Pending',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _expenseData!['status'] == 'Approved' ? Colors.green : (_expenseData!['status'] == 'Rejected' ? Colors.red : Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('Total Req', _expenseData!['total_amount_request']),
                _buildMetric('In Progress', _expenseData!['amount_in_progress']),
                _buildMetric('Claimed', _expenseData!['amount_claimed']),
              ],
            ),
          ],
        ),
      ),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFormsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _forms.length,
      itemBuilder: (context, index) {
        final form = _forms[index];
        final attachments = (form['attachments'] as List?) ?? [];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(form['category'] ?? 'Receipt', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${form['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
              ],
            ),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(DateTime.parse(form['created_at']))),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (form['description'] != null && form['description'].toString().isNotEmpty)
                      Text('Description: ${form['description']}'),
                    
                    const SizedBox(height: 8),
                    if (attachments.isNotEmpty) ...[
                      const Text('Attachments:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...attachments.map((a) => Row(
                        children: [
                          const Icon(Icons.attachment, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(child: Text(a['file_name'] ?? 'File', style: const TextStyle(color: Colors.blue))),
                        ],
                      )).toList(),
                    ],

                    if (_expenseData!['status'] == 'Pending') ...[
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _deleteForm(form['id']),
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}