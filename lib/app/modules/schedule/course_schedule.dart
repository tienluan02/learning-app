import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/controllers/reminder_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/learning_reminder.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/widgets.dart';
import 'package:table_calendar/table_calendar.dart';

class CourseSchedule extends StatefulWidget {
  const CourseSchedule({super.key});

  @override
  State<CourseSchedule> createState() => _CourseScheduleState();
}

class _CourseScheduleState extends State<CourseSchedule> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final ReminderController reminderController =
      Get.isRegistered<ReminderController>()
          ? Get.find<ReminderController>()
          : Get.put(ReminderController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(8.h),
          child: CustomIconButton(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : AppColors.kPrimary.withValues(alpha: 0.14),
            icon: AppAssets.kArrowBackIos,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: const Text('Learning Schedule'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderSheet(initialDate: _selectedDay),
        icon: const Icon(Icons.add),
        label: Text('New reminder for ${_formatSelectedDateShort(_selectedDay)}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSpacing.twentyHorizontal),
              child: _CalendarWidget(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                calendarFormat: _calendarFormat,
                reminderController: reminderController,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
              ),
            ),
            SizedBox(height: AppSpacing.thirtyVertical),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSpacing.twentyHorizontal),
              child: _ReminderSection(
                controller: reminderController,
                selectedDay: _selectedDay,
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
  Future<void> _showAddReminderSheet({DateTime? initialDate}) async {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    var selectedDateTime = initialDate?.add(const Duration(hours: 1)) ??
        DateTime.now().add(const Duration(hours: 1));
    var selectedTime =
        TimeOfDay(hour: selectedDateTime.hour, minute: selectedDateTime.minute);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate() async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDateTime,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setModalState(() {
                  selectedDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                });
              }
            }

            Future<void> pickTime() async {
              final time = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );
              if (time != null) {
                setModalState(() {
                  selectedTime = time;
                  selectedDateTime = DateTime(
                    selectedDateTime.year,
                    selectedDateTime.month,
                    selectedDateTime.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20.w,
                right: 20.w,
              ),
              child: PrimaryContainer(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New reminder', style: AppTypography.kBold18),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: pickDate,
                              icon:
                                  const Icon(Icons.calendar_today_outlined),
                              label: Text(_formatDate(selectedDateTime)),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: pickTime,
                              icon: const Icon(Icons.access_time),
                              label: Text(_formatTime(selectedTime)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      PrimaryButton(
                        onTap: () async {
                          final title = titleController.text.trim();
                          final note = noteController.text.trim();
                          if (title.isEmpty) {
                            Get.snackbar(
                              'Title required',
                              'Give your reminder a title',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          final navigator = Navigator.of(context);
                          await reminderController.addReminder(
                            scheduledAt: selectedDateTime,
                            title: title,
                            note: note.isEmpty ? null : note,
                          );
                          if (navigator.mounted) {
                            navigator.pop();
                          }
                        },
                        text: 'Save reminder',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, ${date.day} $month';
  }

  String _formatTime(TimeOfDay time) {
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatSelectedDateShort(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final ReminderController reminderController;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final void Function(CalendarFormat format) onFormatChanged;
  final void Function(DateTime focusedDay) onPageChanged;

  const _CalendarWidget({
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.reminderController,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  Set<DateTime> _getReminderDates() {
    return reminderController.reminders
        .map((r) => DateTime(r.scheduledAt.year, r.scheduledAt.month, r.scheduledAt.day))
        .toSet();
  }

  List<LearningReminder> _getRemindersForDay(DateTime day) {
    final dayDateOnly = DateTime(day.year, day.month, day.day);
    return reminderController.reminders
        .where((r) {
          final reminderDateOnly = DateTime(
            r.scheduledAt.year,
            r.scheduledAt.month,
            r.scheduledAt.day,
          );
          return reminderDateOnly.isAtSameMomentAs(dayDateOnly);
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Obx(() {
      final reminderDates = _getReminderDates();
      
      return PrimaryContainer(
        padding: EdgeInsets.all(16.w),
        child: TableCalendar<LearningReminder>(
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          calendarFormat: calendarFormat,
          eventLoader: _getRemindersForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            weekendTextStyle: AppTypography.kLight14.copyWith(
              color: isDarkMode ? Colors.white70 : AppColors.kSecondary,
            ),
            defaultTextStyle: AppTypography.kLight14.copyWith(
              color: isDarkMode ? Colors.white : AppColors.kSecondary,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.kPrimary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.kPrimary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: AppColors.kAccent1,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            markerSize: 6,
          ),
          headerStyle: HeaderStyle(
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: AppColors.kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            formatButtonTextStyle: AppTypography.kBold14.copyWith(
              color: AppColors.kPrimary,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: isDarkMode ? Colors.white : AppColors.kSecondary,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.white : AppColors.kSecondary,
            ),
            titleTextStyle: AppTypography.kBold18,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTypography.kLight14.copyWith(
              color: isDarkMode ? Colors.white70 : AppColors.kSecondary,
            ),
            weekendStyle: AppTypography.kLight14.copyWith(
              color: isDarkMode ? Colors.white70 : AppColors.kSecondary,
            ),
          ),
          onDaySelected: onDaySelected,
          onFormatChanged: onFormatChanged,
          onPageChanged: onPageChanged,
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (reminderDates.contains(DateTime(date.year, date.month, date.day))) {
                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 6.w,
                    height: 6.h,
                    decoration: const BoxDecoration(
                      color: AppColors.kAccent1,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  }
}

class _ReminderSection extends StatelessWidget {
  final ReminderController controller;
  final DateTime selectedDay;
  const _ReminderSection({
    required this.controller,
    required this.selectedDay,
  });

  String _formatDateTime(DateTime dateTime) {
    final date =
        '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$date · $hour:$minute $period';
  }

  String _formatSelectedDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final allReminders = controller.reminders;
          final selectedDateOnly = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
          final reminders = allReminders
              .where((r) {
                final reminderDateOnly = DateTime(
                  r.scheduledAt.year,
                  r.scheduledAt.month,
                  r.scheduledAt.day,
                );
                return reminderDateOnly.isAtSameMomentAs(selectedDateOnly);
              })
              .toList();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Reminders for ${_formatSelectedDate(selectedDay)}', style: AppTypography.kBold18),
                  const Spacer(),
                  if (allReminders.isNotEmpty)
                    Text(
                      '${allReminders.length} total',
                      style: AppTypography.kLight14,
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              if (reminders.isEmpty)
                PrimaryContainer(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No reminders for ${_formatSelectedDate(selectedDay)}',
                    style: AppTypography.kBold16,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Tap "New reminder" or a date on the calendar to schedule.',
                    style: AppTypography.kLight14,
                  ),
                ],
              ),
            )
            else
              ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reminders.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return PrimaryContainer(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(reminder.title, style: AppTypography.kBold16),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Text(
                        _formatDateTime(reminder.scheduledAt),
                        style: AppTypography.kLight14,
                      ),
                      if ((reminder.note ?? '').isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            reminder.note!,
                            style: AppTypography.kLight14,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => controller.removeReminder(reminder.id),
                  ),
                ),
              );
            },
          ),
            ],
          );
        }),
      ],
    );
  }
}
