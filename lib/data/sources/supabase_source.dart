import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription.dart';

class SupabaseSource {
  final _client = Supabase.instance.client;

  Future<List<Subscription>> fetchAll() async {
    // Only fetch records for the current user
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final res = await _client
        .from('subscriptions')
        .select()
        .eq('user_id', user.id)
        .order('renewal_date', ascending: true);

    return (res as List).map((e) => Subscription.fromMap(e)).toList();
  }

  Future<void> add(Subscription s) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _client.from('subscriptions').insert(
          s.toMap(user.id),
        );
  }

  Future<void> update(Subscription s) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _client
        .from('subscriptions')
        .update(s.toMap(user.id))
        .eq('id', s.id)
        .eq('user_id', user.id);
  }

  Future<void> remove(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _client
        .from('subscriptions')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);
  }
}
