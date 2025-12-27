// import 'package:flutter/material.dart';
//
// class TakeBreakScreen extends StatefulWidget {
//   const TakeBreakScreen({super.key});
//
//   @override
//   State<TakeBreakScreen> createState() => _TakeBreakScreenState();
// }
//
// class _TakeBreakScreenState extends State<TakeBreakScreen> {
//   static const Color primaryBlue = Color(0xFF0F3A68);
//
//   String selectedBreakType = 'Personal';
//   TimeOfDay? startTime;
//   TimeOfDay? endTime;
//   final TextEditingController notesController = TextEditingController();
//   bool attachLocation = true;
//
//   final List<String> breakTypes = ['Personal', 'Lunch', 'Tea', 'Meeting', 'Other'];
//
//   @override
//   void initState() {
//     super.initState();
//     // Set start time to current time when screen loads
//     startTime = TimeOfDay.now();
//   }
//
//   @override
//   void dispose() {
//     notesController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectTime(BuildContext context, bool isStartTime) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: isStartTime ? (startTime ?? TimeOfDay.now()) : (endTime ?? TimeOfDay.now()),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: primaryBlue,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       setState(() {
//         if (isStartTime) {
//           startTime = picked;
//         } else {
//           endTime = picked;
//         }
//       });
//     }
//   }
//
//   String _formatTime(TimeOfDay time) {
//     final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
//     final minute = time.minute.toString().padLeft(2, '0');
//     final period = time.period == DayPeriod.am ? 'Am' : 'Pm';
//     return '$hour:$minute $period';
//   }
//
//
//
//   void _addBreak() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Break added successfully'),
//         backgroundColor: primaryBlue,
//         duration: Duration(seconds: 2),
//       ),
//     );
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryBlue,
//       body: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 16,
//               left: 24,
//               right: 24,
//               bottom: 24,
//             ),
//             decoration: const BoxDecoration(
//               color: primaryBlue,
//             ),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Icon(
//                     Icons.arrow_back_ios,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//                 const Expanded(
//                   child: Text(
//                     'Take a Break',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 24),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Container(
//               color: const Color(0xFFF8F9FA),
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Break Type',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1A1A1A),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: selectedBreakType,
//                           isExpanded: true,
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A1A1A)),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             color: Color(0xFF1A1A1A),
//                             fontWeight: FontWeight.w500,
//                           ),
//                           items: breakTypes.map((String type) {
//                             return DropdownMenuItem<String>(
//                               value: type,
//                               child: Text(type),
//                             );
//                           }).toList(),
//                           onChanged: (String? newValue) {
//                             if (newValue != null) {
//                               setState(() {
//                                 selectedBreakType = newValue;
//                               });
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Start Time',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF1A1A1A),
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               GestureDetector(
//                                 onTap: () => _selectTime(context, true),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(color: Colors.grey.shade300),
//                                   ),
//                                   child: Text(
//                                     startTime != null ? _formatTime(startTime!) : 'Select',
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       color: Color(0xFF1A1A1A),
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'End Time',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF1A1A1A),
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               GestureDetector(
//                                 onTap: () => _selectTime(context, false),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(color: Colors.grey.shade300),
//                                   ),
//                                   child: Text(
//                                     endTime != null ? _formatTime(endTime!) : 'Select',
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       color: Color(0xFF1A1A1A),
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 18),
//                     const Text(
//                       'Notes',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1A1A1A),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: TextField(
//                         controller: notesController,
//                         maxLines: 5,
//                         decoration: const InputDecoration(
//                           hintText: 'Optional',
//                           hintStyle: TextStyle(
//                             color: Color(0xFF999999),
//                             fontSize: 16,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.all(16),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'Attach Current Location',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF1A1A1A),
//                             ),
//                           ),
//                           Switch(
//                             value: attachLocation,
//                             onChanged: (value) {
//                               setState(() {
//                                 attachLocation = value;
//                               });
//                             },
//                             activeColor: Colors.white,
//                             activeTrackColor: primaryBlue,
//                             inactiveThumbColor: Colors.white,
//                             inactiveTrackColor: Colors.grey.shade400,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 100),
//                     GestureDetector(
//                       onTap: _addBreak,
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(vertical: 18),
//                         decoration: BoxDecoration(
//                           color: primaryBlue,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: primaryBlue.withOpacity(0.3),
//                               spreadRadius: 0,
//                               blurRadius: 12,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: const Text(
//                           'Add Break',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildNavItem(Icons.home_outlined, 'Home', false),
//                 _buildNavItem(Icons.task_alt_outlined, 'Task', false),
//                 _buildNavItem(Icons.calendar_today_outlined, 'Calendar', true),
//                 _buildNavItem(Icons.person_outline, 'Profile', false),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavItem(IconData icon, String label, bool isActive) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           icon,
//           color: isActive ? primaryBlue : Colors.grey,
//           size: 24,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             color: isActive ? primaryBlue : Colors.grey,
//             fontSize: 12,
//             fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class TakeBreakScreen extends StatefulWidget {
  const TakeBreakScreen({super.key});

  @override
  State<TakeBreakScreen> createState() => _TakeBreakScreenState();
}

class _TakeBreakScreenState extends State<TakeBreakScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);

  String selectedBreakType = 'Personal';
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController notesController = TextEditingController();
  bool attachLocation = true;

  final List<String> breakTypes = ['Personal', 'Lunch', 'Tea', 'Meeting', 'Other'];

  @override
  void initState() {
    super.initState();
    // Set start time to current time when screen loads
    startTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? (startTime ?? TimeOfDay.now()) : (endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'Am' : 'Pm';
    return '$hour:$minute $period';
  }

  bool _isEndTimeAfterStartTime() {
    if (startTime == null || endTime == null) return true;

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;

    return endMinutes > startMinutes;
  }

  void _addBreak() {
    // Validate start time
    if (startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start time'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate end time
    if (endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select end time'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate end time is after start time
    if (!_isEndTimeAfterStartTime()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // All validations passed - show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Break added successfully'),
        backgroundColor: primaryBlue,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: primaryBlue,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Take a Break',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Break Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedBreakType,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A1A1A)),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w500,
                          ),
                          items: breakTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedBreakType = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Start Time',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => _selectTime(context, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: startTime == null ? Colors.red.shade300 : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    startTime != null ? _formatTime(startTime!) : 'Select',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: startTime == null ? Colors.red.shade300 : const Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'End Time',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => _selectTime(context, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: endTime == null ? Colors.red.shade300 : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    endTime != null ? _formatTime(endTime!) : 'Select',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: endTime == null ? Colors.red.shade300 : const Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: notesController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Optional',
                          hintStyle: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Attach Current Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Switch(
                            value: attachLocation,
                            onChanged: (value) {
                              setState(() {
                                attachLocation = value;
                              });
                            },
                            activeColor: Colors.white,
                            activeTrackColor: primaryBlue,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                    GestureDetector(
                      onTap: _addBreak,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Add Break',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, 'Home', false),
                _buildNavItem(Icons.task_alt_outlined, 'Task', false),
                _buildNavItem(Icons.calendar_today_outlined, 'Calendar', true),
                _buildNavItem(Icons.person_outline, 'Profile', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? primaryBlue : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? primaryBlue : Colors.grey,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}