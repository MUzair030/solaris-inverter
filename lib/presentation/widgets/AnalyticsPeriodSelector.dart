import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/chart_theme.dart';
import '../viewmodels/energy_analytics_viewmodel.dart';

/// Shared period selector: a Day/Week/Month/Year/Total dropdown plus
/// prev/next chevrons and a calendar button.
///
/// Reads/writes a single [EnergyAnalyticsViewModel] instance via Provider, so
/// it must be instantiated underneath a provider that already owns that view
/// model (see `Mainbottomnavigationview`, where it is created once and shared
/// by both the dashboard's compact analytics card and the Analytics screen).
/// Never duplicate the date/period logic living in the view model elsewhere.
class AnalyticsPeriodSelector extends StatelessWidget {
  const AnalyticsPeriodSelector({super.key});

  String _rangeLabel(EnergyAnalyticsViewModel vm) {
    switch (vm.period) {
      case AnalyticsPeriod.day:
        return DateFormat('EEE, MMM d, yyyy').format(vm.selectedDay);
      case AnalyticsPeriod.week:
        final start =
            vm.selectedDay.subtract(Duration(days: vm.selectedDay.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}';
      case AnalyticsPeriod.month:
        return DateFormat('MMMM yyyy').format(vm.selectedMonth);
      case AnalyticsPeriod.year:
        return vm.selectedYear.year.toString();
      case AnalyticsPeriod.total:
        return 'All Time';
    }
  }

  Future<void> _openCalendar(
      BuildContext context, EnergyAnalyticsViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.calendarAnchor,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      initialDatePickerMode:
          vm.period == AnalyticsPeriod.day || vm.period == AnalyticsPeriod.week
              ? DatePickerMode.day
              : DatePickerMode.year,
      helpText: 'Select date',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );
    if (picked == null) return;
    vm.setDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EnergyAnalyticsViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2E3F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ChartTheme.gridStrong),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AnalyticsPeriod>(
              value: vm.period,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E2130),
              icon: const Icon(Icons.arrow_drop_down, color: ChartTheme.label),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (value) {
                if (value == null) return;
                vm.setPeriod(value);
              },
              items: [
                for (final period in AnalyticsPeriod.values)
                  DropdownMenuItem<AnalyticsPeriod>(
                    value: period,
                    child: Text(
                      period.name[0].toUpperCase() + period.name.substring(1),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (vm.period != AnalyticsPeriod.total) ...[
              _IconButton(icon: Icons.chevron_left, onTap: () => vm.shift(-1)),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                _rangeLabel(vm),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (vm.period != AnalyticsPeriod.total) ...[
              const SizedBox(width: 8),
              _IconButton(icon: Icons.chevron_right, onTap: () => vm.shift(1)),
              const SizedBox(width: 8),
              _IconButton(
                icon: Icons.calendar_month_outlined,
                onTap: () => _openCalendar(context, vm),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2E3F),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: ChartTheme.label),
      ),
    );
  }
}
