import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color primaryBlue = Color(0xFF0F3A68);

  // Support contact details
  static const String supportPhone = '+91 6381464027';
  static const String supportEmail = 'info@pegasos.in';

  // FAQ data
  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I reset my password?',
      'answer':
          'On the login screen, tap "Forgot Password?" and enter your registered email address. You will receive a 6-digit OTP code. Enter the code along with your new password to reset it.',
    },
    {
      'question': 'How do I log a new visit?',
      'answer':
          'From the Home screen, tap the "+" button or "Add Visit" to create a new visit. Fill in the client name, purpose of visit, and other required details, then submit.',
    },
    {
      'question': 'How do I check in at a client location?',
      'answer':
          'When you arrive at the client location, open the scheduled visit and tap "Check In". The app will capture your GPS location and timestamp automatically.',
    },
    {
      'question': 'How do I apply for leave?',
      'answer':
          'Go to your Profile, then tap "Apply for Leave". Select the leave type, date range, and provide a reason. Your manager will be notified for approval.',
    },
    {
      'question': 'How do I submit an expense report?',
      'answer':
          'Navigate to the Expenses section from the Home screen. Tap "Add Expense", fill in the details such as amount, category, and attach any receipts. Submit the form for manager approval.',
    },
    {
      'question': 'How do I update my profile information?',
      'answer':
          'Go to your Profile and tap "Edit Profile". You can update your name, phone number, zone, and other details. Save the changes when done.',
    },
    {
      'question': 'How do I view my assigned tasks?',
      'answer':
          'Your assigned tasks are visible on the Home screen dashboard. You can also tap "Tasks" in the navigation to see all tasks organized by status — pending, in progress, and completed.',
    },
    {
      'question': 'What should I do if the app is not loading?',
      'answer':
          'First, check your internet connection. If the issue persists, try closing the app completely and reopening it. If the problem continues, contact support using the details in the Help tab.',
    },
    {
      'question': 'How do I view my activity history?',
      'answer':
          'Go to your Profile and tap "Activities". This shows a log of all your sign-ins, sign-outs, visits, and other actions with timestamps and locations.',
    },
    {
      'question': 'Can I change my login email?',
      'answer':
          'Currently, your login email is set during account registration. To change it, please contact your administrator or reach out to support for assistance.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchPhone() async {
    final uri = Uri(scheme: 'tel', path: supportPhone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': 'Support Request — Pegasos Field Management',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Support',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Help'),
            Tab(text: 'FAQs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHelpTab(),
          _buildFaqsTab(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // HELP TAB
  // ─────────────────────────────────────────
  Widget _buildHelpTab() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                size: 40,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'We\'re Here to Help',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'For any assistance, please contact us using the details below.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Phone card
            _buildContactCard(
              icon: Icons.phone,
              label: 'Phone Support',
              value: supportPhone,
              subtitle: 'Mon — Sat, 9 AM — 6 PM',
              onTap: _launchPhone,
            ),
            const SizedBox(height: 16),

            // Email card
            _buildContactCard(
              icon: Icons.email_outlined,
              label: 'Email Support',
              value: supportEmail,
              subtitle: 'We usually respond within 24 hours',
              onTap: _launchEmail,
            ),

            const SizedBox(height: 36),

            // Additional info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryBlue.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primaryBlue.withOpacity(0.7),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For urgent issues, please call our support line directly for the fastest response.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: primaryBlue.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // FAQs TAB
  // ─────────────────────────────────────────
  Widget _buildFaqsTab() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Find answers to common questions below.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // FAQ items
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  children: List.generate(_faqs.length, (index) {
                    final faq = _faqs[index];
                    return Column(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            childrenPadding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 16,
                            ),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Q${index + 1}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              faq['question']!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            iconColor: primaryBlue,
                            collapsedIconColor: Colors.grey[400],
                            children: [
                              Text(
                                faq['answer']!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index < _faqs.length - 1)
                          Divider(
                            height: 1,
                            indent: 20,
                            endIndent: 20,
                            color: Colors.grey.shade200,
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Can't find answer section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: primaryBlue.withOpacity(0.15),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 32,
                    color: primaryBlue.withOpacity(0.7),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Can\'t find what you\'re looking for?',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Switch to the Help tab to contact our support team directly.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _tabController.animateTo(0);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryBlue,
                        side: const BorderSide(color: primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Contact Support',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
