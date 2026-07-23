import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  // Sample notifications data
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'New Task Assigned',
      'message': 'Follow-up with Mr. Rajesh at 3:00PM',
      'type': 'task_assigned',
      'time': '10 mins ago',
      'isRead': false,
    },
    {
      'title': 'Message from Manager',
      'message': 'Please Complete your task for the day',
      'type': 'message',
      'time': '1 hour ago',
      'isRead': false,
    },
    {
      'title': 'New Task Assigned',
      'message': 'Follow-up with Mr.Kumar at 5:00 PM',
      'type': 'task_assigned',
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'title': 'Missed Visit Alert',
      'message': 'Collect Documents from Ms. Fatima',
      'type': 'missed_visit',
      'time': '3 hours ago',
      'isRead': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? Column(
        children: [
          // Filter Tabs
          Container(
            color: AppColors.lightGray,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.darkGray,
              indicator: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(25),
              ),
              tabs: ['All', 'Today', 'Task Update', 'From Manager']
                  .map((filter) => Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(filter),
                ),
              ))
                  .toList(),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications,
                    size: 80,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "You're all Caught up!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No New Notifications for now',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : Column(
        children: [
          // Filter Tabs
          Container(
            color: AppColors.lightGray,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.darkGray,
              indicator: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(25),
              ),
              tabs: ['All', 'Today', 'Task Update', 'From Manager']
                  .map((filter) => Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(filter),
                ),
              ))
                  .toList(),
            ),
          ),
          // Notifications List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    IconData icon;
    Color iconColor;

    switch (notification['type']) {
      case 'task_assigned':
        icon = Icons.assignment;
        iconColor = Colors.red;
        break;
      case 'message':
        icon = Icons.message;
        iconColor = AppColors.primaryBlue;
        break;
      case 'missed_visit':
        icon = Icons.schedule;
        iconColor = AppColors.primaryBlue;
        break;
      default:
        icon = Icons.notifications;
        iconColor = AppColors.primaryBlue;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.darkGray),
        ],
      ),
    );
  }
}