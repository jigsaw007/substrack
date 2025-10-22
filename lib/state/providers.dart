import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/subscription.dart';
import '../data/repository.dart';
import '../data/sources/supabase_source.dart';

// ✅ Supabase data source provider (must come first)
final supabaseSourceProvider = Provider((_) => SupabaseSource());

// ✅ Repository provider that depends on SupabaseSource
final repoProvider =
    Provider((ref) => Repository(ref.watch(supabaseSourceProvider)));

// 🧠 Reactive StateNotifier for subscriptions
class SubscriptionsNotifier
    extends StateNotifier<AsyncValue<List<Subscription>>> {
  final Repository repo;

  SubscriptionsNotifier(this.repo) : super(const AsyncLoading()) {
    load();
  }

  // Load subscriptions from Supabase
  Future<void> load() async {
    try {
      final items = await repo.list();
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Add instantly (optimistic update)
  Future<void> add(Subscription s) async {
    final current = state.value ?? [];
    state = AsyncData([...current, s]); // instant UI update

    try {
      await repo.create(s); // save to Supabase
      await load(); // optional re-sync
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Delete instantly (optimistic removal)
  Future<void> remove(String id) async {
    final current = state.value ?? [];
    state = AsyncData(current.where((e) => e.id != id).toList());
    try {
      await repo.delete(id);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// ✅ Public provider your UI will watch
final subscriptionsProvider = StateNotifierProvider<SubscriptionsNotifier,
    AsyncValue<List<Subscription>>>(
  (ref) => SubscriptionsNotifier(ref.watch(repoProvider)),
);
