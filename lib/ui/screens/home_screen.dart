import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../state/providers.dart';
import '../../data/models/subscription.dart';
import '../../data/repository.dart';
import '../widgets/section_card.dart';
import '../widgets/add_subscription_sheet.dart';
import 'stats_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/category_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSubs = ref.watch(subscriptionsProvider);
    final repo = ref.watch(repoProvider);
    final user = Supabase.instance.client.auth.currentUser;

    // --- Summary Section ---
    Widget summary(List<Subscription> items) {
      final total = repo.monthlyTotal(items);
      return SectionCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Monthly Cost',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                '¥$total',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // --- Upcoming Renewals Section ---
    Widget upcoming(List<Subscription> items) {
      if (items.isEmpty) {
        return const SectionCard(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No active subscriptions yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        );
      }

      final upcoming = [...items]..sort(
          (a, b) => a.renewalDate.compareTo(b.renewalDate),
        );

      return SectionCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Renewals',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
              ),
              const SizedBox(height: 10),
              ...upcoming.take(5).map(
                    (s) => Dismissible(
                      key: ValueKey(s.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Subscription'),
                            content: Text(
                                'Are you sure you want to delete "${s.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        final repo = ref.read(repoProvider);
                        try {
                          await repo.delete(s.id);
                          ref.invalidate(subscriptionsProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${s.name} deleted')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete: $e')),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: CategoryColors.forCategory(
                                    s.category ?? 'Other')
                                .withOpacity(0.2),
                            child: Icon(Icons.subscriptions,
                                color: CategoryColors.forCategory(
                                    s.category ?? 'Other')),
                          ),
                          title: Text(
                            s.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${s.cycle} • ¥${s.price.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Text(
                            '${s.renewalDate.toLocal().toString().split(' ').first}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      );
    }

    // --- Main Build ---
    return asyncSubs.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (List<Subscription> items) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.white.withOpacity(0.8),
                elevation: 3,
                title: const Text(
                  'SubTrack Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bar_chart_outlined,
                        color: Colors.teal),
                    tooltip: 'View Stats',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StatsScreen()),
                      );
                    },
                  ),
                  if (user != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          user.email ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    tooltip: 'Logout',
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/auth');
                      }
                    },
                  ),
                ],
              ),
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF8FBFF), Color(0xFFE9EEF3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListView(
                                children: [
                                  const SizedBox(height: 80),
                                  summary(items),
                                  const SizedBox(height: 16),
                                  upcoming(items),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ListView(
                                children: [
                                  const SizedBox(height: 80),
                                  SectionCard(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Spending Overview',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[800],
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            height: 220,
                                            child: Builder(
                                              builder: (_) {
                                                if (items.isEmpty) {
                                                  return const Center(
                                                    child: Text(
                                                      'No data yet',
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                  );
                                                }

                                                final categoryTotals =
                                                    <String, double>{};
                                                for (final s in items) {
                                                  final key =
                                                      s.category?.isNotEmpty ==
                                                              true
                                                          ? s.category!
                                                          : 'Other';
                                                  categoryTotals[key] =
                                                      (categoryTotals[key] ??
                                                              0) +
                                                          s.price;
                                                }

                                                final pieSections =
                                                    categoryTotals.entries
                                                        .map((entry) {
                                                  return PieChartSectionData(
                                                    title: '',
                                                    color: CategoryColors
                                                        .forCategory(entry.key),
                                                    value: entry.value,
                                                    radius: 55,
                                                  );
                                                }).toList();

                                                return PieChart(
                                                  PieChartData(
                                                    sections: pieSections,
                                                    centerSpaceRadius: 50,
                                                    sectionsSpace: 2,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Builder(builder: (_) {
                                            if (items.isEmpty) {
                                              return const SizedBox.shrink();
                                            }

                                            final total = items.fold<double>(
                                                0.0, (sum, s) => sum + s.price);
                                            final count = items.length;

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total: ¥${total.toStringAsFixed(0)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        color: Colors.teal[700],
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                                Text(
                                                  '$count subscriptions tracked',
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                              ],
                                            );
                                          }),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          const StatsScreen()),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.bar_chart_outlined,
                                                color: Colors.teal,
                                              ),
                                              label: const Text(
                                                "View Full Stats",
                                                style: TextStyle(
                                                    color: Colors.teal),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          children: [
                            const SizedBox(height: 80),
                            summary(items),
                            const SizedBox(height: 16),
                            upcoming(items),
                            const SizedBox(height: 16),
                            SectionCard(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Center(
                                  child: Text(
                                    'Stats Section (coming soon)',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              floatingActionButton: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.85),
                      Colors.white.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => const AddSubscriptionSheet(),
                    );
                  },
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: const Icon(Icons.add, size: 32, color: Colors.teal),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
