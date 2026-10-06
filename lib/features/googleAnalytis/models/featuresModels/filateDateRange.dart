class DateRangeOption {
  final String label;
  final String startDate; // GA4 format
  final String endDate;

  const DateRangeOption({
    required this.label,
    required this.startDate,
    required this.endDate,
  });

  static const List<DateRangeOption> options = [
    DateRangeOption(label: 'Today', startDate: 'today', endDate: 'today'),
    DateRangeOption(
        label: 'Yesterday', startDate: 'yesterday', endDate: 'yesterday'),
    DateRangeOption(
        label: 'Last 7 days', startDate: '7daysAgo', endDate: 'today'),
    DateRangeOption(
        label: 'Last 28 days', startDate: '28daysAgo', endDate: 'today'),
    DateRangeOption(
        label: 'Last 30 days', startDate: '30daysAgo', endDate: 'today'),
    DateRangeOption(
        label: 'Last 90 days', startDate: '90daysAgo', endDate: 'today'),
  ];

  static DateRangeOption get defaultOption => options[2]; // Last 7 days
}