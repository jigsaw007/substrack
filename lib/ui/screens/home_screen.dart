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

    Widget summary(List<Subscription> items) {
      final total = repo.monthlyTotal(items);
      return SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Monthly Cost',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '¥$total',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      );
    }

    Widget upcoming(List<Subscription> items) {
      if (items.isEmpty) {
        return const SectionCard(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Renewals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final s in upcoming.take(5))
              Dismissible(
                key: ValueKey(s.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Subscription'),
                      content:
                          Text('Are you sure you want to delete "${s.name}"?'),
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
                child: ListTile(
                  dense: true,
                  title: Text(s.name),
                  subtitle: Text('${s.cycle} • ¥${s.price.toStringAsFixed(0)}'),
                  trailing: Text(
                    '${s.renewalDate.toLocal().toString().split(' ').first}',
                  ),
                ),
              ),
          ],
        ),
      );
    }

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
              appBar: AppBar(
                title: const Text('SubTrack Dashboard'),
                actions: [
                  // ✅ Open Stats Screen button
                  IconButton(
                    icon: const Icon(Icons.bar_chart_outlined),
                    tooltip: 'View Stats',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StatsScreen()),
                      );
                    },
                  ),

                  // ✅ Display user email (as before)
                  if (user != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          user.email ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  // ✅ Logout button (unchanged)
                  IconButton(
                    icon: const Icon(Icons.logout),
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
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                summary(items),
                                upcoming(items),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                SectionCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Spending Overview',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 12),

                                      // Small pie chart preview
                                      SizedBox(
                                        height: 200,
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
                                                  s.category?.isNotEmpty == true
                                                      ? s.category!
                                                      : 'Other';
                                              categoryTotals[key] =
                                                  (categoryTotals[key] ?? 0) +
                                                      s.price;
                                            }

                                            final pieSections = categoryTotals
                                                .entries
                                                .map((entry) {
                                              return PieChartSectionData(
                                                title: '',
                                                color: CategoryColors
                                                    .forCategory(entry
                                                        .key), // 👈 uses consistent category colors
                                                value: entry.value,
                                                radius: 50,
                                              );
                                            }).toList();

                                            return PieChart(
                                              PieChartData(
                                                sections: pieSections,
                                                centerSpaceRadius: 40,
                                                sectionsSpace: 1,
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Display quick summary
                                      Builder(builder: (_) {
                                        if (items.isEmpty)
                                          return const SizedBox.shrink();

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
                                                      color: Colors.teal),
                                            ),
                                            Text(
                                              '$count subscriptions tracked',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      color: Colors.grey),
                                            ),
                                          ],
                                        );
                                      }),

                                      const SizedBox(height: 8),

                                      // Button to open full Stats page
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
                                              color: Colors.teal),
                                          label: const Text(
                                            "View Full Stats",
                                            style:
                                                TextStyle(color: Colors.teal),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        children: [
                          summary(items),
                          upcoming(items),
                          const SectionCard(
                            child: Center(
                              child: Text(
                                'Stats Section (coming soon)',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const AddSubscriptionSheet(),
                  );
                },
                child: const Icon(Icons.add),
              ),
            );
          },
        );
      },
    );
  }
}
