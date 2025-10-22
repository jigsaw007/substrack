import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import '../../state/providers.dart';
import '../../data/models/subscription.dart';
import '../widgets/section_card.dart';
import '../../utils/category_colors.dart'; // Add this at top

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  double animatedTotal = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void animateTotal(double target) {
    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {
        if (animatedTotal < target) {
          animatedTotal += (target / 50); // smooth 1s ramp
          if (animatedTotal >= target) {
            animatedTotal = target;
            timer.cancel();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncSubs = ref.watch(subscriptionsProvider);

    return asyncSubs.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text("Statistics")),
        body: Center(child: Text('Error: $error')),
      ),
      data: (List<Subscription> items) {
        if (items.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Statistics")),
            body: const Center(
              child: Text(
                "No subscriptions found to generate stats.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // --- Aggregate data ---
        final categoryTotals = <String, double>{};
        for (final s in items) {
          final key = s.category?.isNotEmpty == true ? s.category! : 'Other';
          categoryTotals[key] = (categoryTotals[key] ?? 0) + s.price;
        }
        final total = categoryTotals.values.fold(0.0, (a, b) => a + b);
        animateTotal(total);

        final pieSections = categoryTotals.entries.map((entry) {
          final color = CategoryColors.forCategory(entry.key);
          return PieChartSectionData(
            title: entry.key,
            color: color,
            value: entry.value,
            radius: 70,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
          );
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
          ),
          body: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              _controller.forward();
              return FadeTransition(
                opacity: _controller,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                      parent: _controller, curve: Curves.easeOut),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Spending by Category',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 250,
                                child: PieChart(
                                  PieChartData(
                                    startDegreeOffset: 180 *
                                        _controller.value, // rotate animation
                                    sections: pieSections,
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  'Total: ¥${animatedTotal.toStringAsFixed(0)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Details by Category',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Divider(),
                              for (final entry in categoryTotals.entries)
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        CategoryColors.forCategory(entry.key),
                                    radius: 8,
                                  ),
                                  title: Text(entry.key),
                                  trailing: Text(
                                      '¥${entry.value.toStringAsFixed(0)}'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
