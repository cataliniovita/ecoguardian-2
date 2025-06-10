import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/report_provider.dart';
import '../models/report.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          if (reportProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Statistics
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Reports',
                        value: '${reportProvider.totalReports}',
                        icon: Icons.report,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Pending',
                        value: '${reportProvider.pendingReports.length}',
                        icon: Icons.pending,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Resolved',
                        value: '${reportProvider.resolvedReports.length}',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'This Month',
                        value: '${_getThisMonthReports(reportProvider.reports)}',
                        icon: Icons.calendar_month,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Category Breakdown
                Text(
                  'Reports by Category',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                ...ReportCategory.values.map((category) {
                  final count = reportProvider.getReportCountByCategory(category);
                  final percentage = reportProvider.totalReports > 0 
                      ? (count / reportProvider.totalReports * 100)
                      : 0.0;
                  
                  return _CategoryProgressCard(
                    category: category,
                    count: count,
                    percentage: percentage,
                  );
                }).toList(),
                
                const SizedBox(height: 24),
                
                // Status Breakdown
                Text(
                  'Status Distribution',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                _StatusChart(reports: reportProvider.reports),
                
                const SizedBox(height: 24),
                
                // Recent Activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                _RecentActivityChart(reports: reportProvider.reports),
                
                const SizedBox(height: 24),
                
                // Environmental Impact
                Text(
                  'Environmental Impact',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                _ImpactCards(reports: reportProvider.reports),
              ],
            ),
          );
        },
      ),
    );
  }

  int _getThisMonthReports(List<Report> reports) {
    final now = DateTime.now();
    return reports.where((report) {
      return report.createdAt.year == now.year && 
             report.createdAt.month == now.month;
    }).length;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryProgressCard extends StatelessWidget {
  final ReportCategory category;
  final int count;
  final double percentage;

  const _CategoryProgressCard({
    required this.category,
    required this.count,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(category.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '$count reports (${percentage.toStringAsFixed(1)}%)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChart extends StatelessWidget {
  final List<Report> reports;

  const _StatusChart({required this.reports});

  @override
  Widget build(BuildContext context) {
    final statusCounts = <ReportStatus, int>{};
    for (final status in ReportStatus.values) {
      statusCounts[status] = reports.where((r) => r.status == status).length;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: statusCounts.entries.map((entry) {
            final percentage = reports.isNotEmpty 
                ? (entry.value / reports.length * 100)
                : 0.0;
            
            Color color;
            switch (entry.key) {
              case ReportStatus.pending:
                color = Colors.orange;
                break;
              case ReportStatus.investigating:
                color = Colors.blue;
                break;
              case ReportStatus.resolved:
                color = Colors.green;
                break;
              case ReportStatus.rejected:
                color = Colors.red;
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(entry.key.displayName),
                  ),
                  Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RecentActivityChart extends StatelessWidget {
  final List<Report> reports;

  const _RecentActivityChart({required this.reports});

  @override
  Widget build(BuildContext context) {
    final last7Days = <DateTime, int>{};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      last7Days[date] = 0;
    }

    for (final report in reports) {
      final reportDate = DateTime(
        report.createdAt.year,
        report.createdAt.month,
        report.createdAt.day,
      );
      if (last7Days.containsKey(reportDate)) {
        last7Days[reportDate] = last7Days[reportDate]! + 1;
      }
    }

    final maxValue = last7Days.values.isNotEmpty 
        ? last7Days.values.reduce((a, b) => a > b ? a : b)
        : 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last 7 Days',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: last7Days.entries.map((entry) {
                final height = maxValue > 0 ? (entry.value / maxValue * 100) : 0.0;
                final dayName = _getDayName(entry.key.weekday);
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Text(
                          '${entry.value}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height + 10,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}

class _ImpactCards extends StatelessWidget {
  final List<Report> reports;

  const _ImpactCards({required this.reports});

  @override
  Widget build(BuildContext context) {
    final resolvedCount = reports.where((r) => r.status == ReportStatus.resolved).length;
    final avgResolutionTime = _calculateAverageResolutionTime();
    final criticalIssues = reports.where((r) => 
      r.category == ReportCategory.waterPollution || 
      r.category == ReportCategory.airPollution
    ).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ImpactCard(
                title: 'Issues Resolved',
                value: '$resolvedCount',
                subtitle: 'Environmental improvements',
                icon: Icons.eco,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ImpactCard(
                title: 'Avg. Resolution',
                value: '${avgResolutionTime}d',
                subtitle: 'Response time',
                icon: Icons.timer,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _ImpactCard(
            title: 'Critical Issues',
            value: '$criticalIssues',
            subtitle: 'Water & air pollution reports requiring immediate attention',
            icon: Icons.warning,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  int _calculateAverageResolutionTime() {
    final resolvedReports = reports.where((r) => r.status == ReportStatus.resolved).toList();
    if (resolvedReports.isEmpty) return 0;

    final totalDays = resolvedReports.map((report) {
      return DateTime.now().difference(report.createdAt).inDays;
    }).reduce((a, b) => a + b);

    return (totalDays / resolvedReports.length).round();
  }
}

class _ImpactCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ImpactCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 