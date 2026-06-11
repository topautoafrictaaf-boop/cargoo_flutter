import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Authentification
  static Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  static Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }

  // Utilisateurs
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  static Future<void> createUserProfile(String userId, String firstName, String lastName, String email) async {
    await _client.from('users').insert({
      'id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Véhicules
  static Future<List<Map<String, dynamic>>> getUserVehicles(String userId) async {
    final response = await _client
        .from('vehicles')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addVehicle(
    String userId,
    String brand,
    String model,
    int year,
    String fuelType,
  ) async {
    await _client.from('vehicles').insert({
      'user_id': userId,
      'brand': brand,
      'model': model,
      'year': year,
      'fuel_type': fuelType,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Produits
  static Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _client.from('products').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Panier
  static Future<void> addToCart(String userId, String productId, int quantity) async {
    await _client.from('cart_items').insert({
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getCart(String userId) async {
    final response = await _client
        .from('cart_items')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> removeFromCart(String cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  // Commandes
  static Future<void> createOrder(String userId, double total) async {
    await _client.from('orders').insert({
      'user_id': userId,
      'total': total,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    final response = await _client
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}