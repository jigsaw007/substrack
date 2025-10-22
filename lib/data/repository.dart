import '../data/models/subscription.dart';
import '../data/sources/supabase_source.dart';

class Repository {
  final SupabaseSource source;

  Repository(this.source);

  /// Fetch all subscriptions for the current user
  Future<List<Subscription>> list() => source.fetchAll();

  /// Add a new subscription
  Future<void> create(Subscription s) => source.add(s);

  /// Edit/update an existing subscription
  Future<void> edit(Subscription s) => source.update(s);

  /// Delete a subscription by ID
  Future<void> delete(String id) => source.remove(id);

  /// Calculate total monthly cost (convert weekly/yearly → monthly equivalent)
  double monthlyTotal(List<Subscription> items) {
    double total = 0;
    for (final s in items) {
      switch (s.cycle) {
        case 'monthly':
          total += s.price;
          break;
        case 'yearly':
          total += s.price / 12.0;
          break;
        case 'weekly':
          total += s.price * 4.345; // average weeks per month
          break;
        default:
          total += s.price;
      }
    }

    // Round to nearest whole number for display
    return double.parse(total.toStringAsFixed(0));
  }
}
