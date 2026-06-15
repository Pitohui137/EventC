import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/index.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // ==================== USER SERVICES ====================

  /// Register new user
  Future<User?> registerUser({
    required String email,
    required String password,
    required String nama,
    required String role,
    String? nomorHP,
    String? asal,
  }) async {
    try {
      // Register in Auth
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return null;
      }

      // Insert user data
      await client.from('users').insert({
        'id': authResponse.user!.id,
        'email': email,
        'nama': nama,
        'role': role,
        'nomor_hp': nomorHP,
        'asal': asal,
      });

      return User(
        id: authResponse.user!.id,
        email: email,
        nama: nama,
        role: role,
        nomorHP: nomorHP,
        asal: asal,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  /// Login user
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        return null;
      }

      final response = await client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .single();

      return User.fromJson(response);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Logout user
  Future<void> logoutUser() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  // ==================== EVENT SERVICES ====================

  /// Get all events
  Future<List<Event>> getAllEvents() async {
    try {
      final response = await client
          .from('event')
          .select()
          .order('tanggal_mulai', ascending: true);

      return List<Event>.from(response.map((e) => Event.fromJson(e)));
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  /// Get event by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final response = await client
          .from('event')
          .select()
          .eq('id', eventId)
          .single();

      return Event.fromJson(response);
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }

  /// Create event (Admin only)
  Future<Event?> createEvent({
    required String nama,
    required String deskripsi,
    required String tipe,
    required String lokasi,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    required DateTime batasPendaftaran,
    required int kapasitas,
    required String adminId,
  }) async {
    try {
      final response = await client.from('event').insert({
        'nama': nama,
        'deskripsi': deskripsi,
        'tipe': tipe,
        'lokasi': lokasi,
        'tanggal_mulai': tanggalMulai.toIso8601String(),
        'tanggal_selesai': tanggalSelesai.toIso8601String(),
        'batas_pendaftaran': batasPendaftaran.toIso8601String(),
        'kapasitas': kapasitas,
        'terdaftar': 0,
        'pendaftaran_ditutup': false,
        'admin_id': adminId,
      }).select().single();

      return Event.fromJson(response);
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  /// Update event (Admin only)
  Future<Event?> updateEvent({
    required String eventId,
    required String nama,
    required String deskripsi,
    required String tipe,
    required String lokasi,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    required DateTime batasPendaftaran,
    required int kapasitas,
  }) async {
    try {
      final response = await client
          .from('event')
          .update({
            'nama': nama,
            'deskripsi': deskripsi,
            'tipe': tipe,
            'lokasi': lokasi,
            'tanggal_mulai': tanggalMulai.toIso8601String(),
            'tanggal_selesai': tanggalSelesai.toIso8601String(),
            'batas_pendaftaran': batasPendaftaran.toIso8601String(),
            'kapasitas': kapasitas,
          })
          .eq('id', eventId)
          .select()
          .single();

      return Event.fromJson(response);
    } catch (e) {
      print('Error updating event: $e');
      return null;
    }
  }

  /// Close event registration (Admin only)
  Future<bool> closeEventRegistration(String eventId) async {
    try {
      await client
          .from('event')
          .update({'pendaftaran_ditutup': true}).eq('id', eventId);
      return true;
    } catch (e) {
      print('Error closing registration: $e');
      return false;
    }
  }

  // ==================== REGISTRATION SERVICES ====================

  /// Register user for event
  Future<Pendaftaran?> registerForEvent({
    required String userId,
    required String eventId,
  }) async {
    try {
      // Check if already registered
      final existing = await client
          .from('pendaftaran')
          .select()
          .eq('user_id', userId)
          .eq('event_id', eventId);

      if (existing.isNotEmpty) {
        return null; // Already registered
      }

      // Get event details
      final event = await getEventById(eventId);
      if (event == null) return null;

      // Check capacity
      if (event.terdaftar >= event.kapasitas) {
        return null; // Event full
      }

      // Check registration deadline
      if (DateTime.now().isAfter(event.batasPendaftaran)) {
        return null; // Registration closed
      }

      // Register
      final response = await client
          .from('pendaftaran')
          .insert({
            'user_id': userId,
            'event_id': eventId,
            'tanggal_daftar': DateTime.now().toIso8601String(),
            'status': 'aktif',
          })
          .select()
          .single();

      // Update event terdaftar count
      await client
          .from('event')
          .update({'terdaftar': event.terdaftar + 1}).eq('id', eventId);

      return Pendaftaran.fromJson(response);
    } catch (e) {
      print('Error registering for event: $e');
      return null;
    }
  }

  /// Get user registrations
  Future<List<Pendaftaran>> getUserRegistrations(String userId) async {
    try {
      final response = await client
          .from('pendaftaran')
          .select()
          .eq('user_id', userId)
          .order('tanggal_daftar', ascending: false);

      return List<Pendaftaran>.from(
          response.map((e) => Pendaftaran.fromJson(e)));
    } catch (e) {
      print('Error fetching registrations: $e');
      return [];
    }
  }

  /// Get event participants
  Future<List<Pendaftaran>> getEventParticipants(String eventId) async {
    try {
      final response = await client
          .from('pendaftaran')
          .select()
          .eq('event_id', eventId)
          .eq('status', 'aktif');

      return List<Pendaftaran>.from(
          response.map((e) => Pendaftaran.fromJson(e)));
    } catch (e) {
      print('Error fetching participants: $e');
      return [];
    }
  }

  /// Cancel registration
  Future<bool> cancelRegistration(String pendaftaranId) async {
    try {
      await client
          .from('pendaftaran')
          .update({'status': 'batal'}).eq('id', pendaftaranId);
      return true;
    } catch (e) {
      print('Error cancelling registration: $e');
      return false;
    }
  }

  // ==================== TICKET SERVICES ====================

  /// Get user tickets
  Future<List<Tiket>> getUserTickets(String userId) async {
    try {
      final response = await client
          .from('tiket')
          .select('*, pendaftaran(user_id)')
          .order('tanggal_buat', ascending: false);

      // Filter tickets for current user
      List<Tiket> userTickets = [];
      for (var ticket in response) {
        if (ticket['pendaftaran']['user_id'] == userId) {
          userTickets.add(Tiket.fromJson(ticket));
        }
      }

      return userTickets;
    } catch (e) {
      print('Error fetching tickets: $e');
      return [];
    }
  }

  /// Get ticket by ID
  Future<Tiket?> getTicketById(String ticketId) async {
    try {
      final response = await client
          .from('tiket')
          .select()
          .eq('id', ticketId)
          .single();

      return Tiket.fromJson(response);
    } catch (e) {
      print('Error fetching ticket: $e');
      return null;
    }
  }

  /// Create ticket after registration
  Future<Tiket?> createTicket({
    required String pendaftaranId,
    required String qrCode,
  }) async {
    try {
      final nomorTiket = 'TKT-${DateTime.now().millisecondsSinceEpoch}';

      final response = await client
          .from('tiket')
          .insert({
            'pendaftaran_id': pendaftaranId,
            'nomor_tiket': nomorTiket,
            'qr_code': qrCode,
            'tanggal_buat': DateTime.now().toIso8601String(),
            'sudah_digunakan': false,
          })
          .select()
          .single();

      return Tiket.fromJson(response);
    } catch (e) {
      print('Error creating ticket: $e');
      return null;
    }
  }
}
