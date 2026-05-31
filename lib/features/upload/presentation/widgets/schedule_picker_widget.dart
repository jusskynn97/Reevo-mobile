import 'package:flutter/material.dart';
import 'package:reevo/core/theme/color.dart';

/// Widget for scheduling video upload with date and time pickers.
class SchedulePickerWidget extends StatelessWidget {
  final bool isScheduled;
  final DateTime? scheduledDateTime;
  final VoidCallback onToggle;
  final ValueChanged<DateTime> onDateTimeChanged;

  const SchedulePickerWidget({
    super.key,
    required this.isScheduled,
    this.scheduledDateTime,
    required this.onToggle,
    required this.onDateTimeChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: scheduledDateTime ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.brand,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.background,
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final currentTime = scheduledDateTime ?? now.add(const Duration(hours: 1));
      onDateTimeChanged(DateTime(
        date.year,
        date.month,
        date.day,
        currentTime.hour,
        currentTime.minute,
      ));
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final now = DateTime.now();
    final currentDateTime = scheduledDateTime ?? now.add(const Duration(hours: 1));
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.brand,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.background,
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      onDateTimeChanged(DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        time.hour,
        time.minute,
      ));
    }
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dt.month - 1];
    final day = dt.day;
    final year = dt.year;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year at $hour:$minute $period';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Schedule toggle row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isScheduled
                      ? AppColors.brand.withOpacity(0.15)
                      : AppColors.grey5,
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: isScheduled ? AppColors.brand : AppColors.grey3,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Schedule Upload',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isScheduled && scheduledDateTime != null
                          ? _formatDateTime(scheduledDateTime!)
                          : 'Post later at a specific time',
                      style: TextStyle(
                        color: isScheduled ? AppColors.brand : AppColors.grey3,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isScheduled,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.brand,
                activeTrackColor: AppColors.brand.withOpacity(0.3),
                inactiveThumbColor: AppColors.grey3,
                inactiveTrackColor: AppColors.grey5,
              ),
            ],
          ),
        ),

        // Date/Time picker (shown when scheduled)
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isScheduled
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Date picker chip
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.brand.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      color: AppColors.brand,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      scheduledDateTime != null
                                          ? _formatDate(scheduledDateTime!)
                                          : 'Select Date',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Time picker chip
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickTime(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.brand.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      color: AppColors.brand,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      scheduledDateTime != null
                                          ? _formatTime(scheduledDateTime!)
                                          : 'Select Time',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Validation warning
                      if (scheduledDateTime != null &&
                          scheduledDateTime!.isBefore(DateTime.now()))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.error,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Scheduled time must be in the future',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
