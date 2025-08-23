import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateChanged;
  final String labelText;

  const CustomDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.labelText = 'Select Date',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.textLight.withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.backgroundLight,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelText,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : 'Choose date',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedDate != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppTheme.primaryBlue,
                onPrimary: Colors.white,
                surface: AppTheme.backgroundLight,
                onSurface: AppTheme.textPrimary,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        print('✅ Date selected: ${_formatDate(picked)}');
        onDateChanged(picked);
      } else {
        print('❌ Date selection cancelled');
      }
    } catch (e) {
      print('❌ Error selecting date: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting date: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Alternative simple date picker for web compatibility
class SimpleDatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateChanged;
  final String labelText;

  const SimpleDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.labelText = 'Select Date',
  });

  @override
  State<SimpleDatePicker> createState() => _SimpleDatePickerState();
}

class _SimpleDatePickerState extends State<SimpleDatePicker> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.selectedDate != null
          ? _formatDate(widget.selectedDate!)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: Icon(
          Icons.calendar_today,
          color: AppTheme.primaryColor,
        ),
        suffixIcon: Icon(
          Icons.arrow_drop_down,
          color: AppTheme.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.borderColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.borderColor,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: AppTheme.cardBackground,
      ),
      onTap: () => _showCustomDatePicker(context),
    );
  }

  Future<void> _showCustomDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final selectedDate = widget.selectedDate ?? now;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: now.subtract(const Duration(days: 30)),
                  lastDate: now.add(const Duration(days: 365)),
                  onDateChanged: (date) {
                    _controller.text = _formatDate(date);
                    widget.onDateChanged(date);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
