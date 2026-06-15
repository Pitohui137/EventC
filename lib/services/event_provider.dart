import 'package:flutter/material.dart';
import '../models/index.dart';
import './supabase_service.dart';

class EventProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Event> _events = [];
  Event? _selectedEvent;
  List<Pendaftaran> _eventParticipants = [];
  List<Pendaftaran> _userRegistrations = [];
  List<Tiket> _userTickets = [];
  Tiket? _selectedTicket;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Event> get events => _events;
  Event? get selectedEvent => _selectedEvent;
  List<Pendaftaran> get eventParticipants => _eventParticipants;
  List<Pendaftaran> get userRegistrations => _userRegistrations;
  List<Tiket> get userTickets => _userTickets;
  Tiket? get selectedTicket => _selectedTicket;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==================== EVENT OPERATIONS ====================

  /// Fetch all events
  Future<void> fetchAllEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _supabaseService.getAllEvents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat event: $e';
      notifyListeners();
    }
  }

  /// Create new event
  Future<bool> createEvent({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validation
      if (nama.isEmpty || deskripsi.isEmpty || lokasi.isEmpty) {
        _errorMessage = 'Semua field wajib diisi';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (kapasitas <= 0) {
        _errorMessage = 'Kapasitas harus lebih dari 0';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (tanggalMulai.isAfter(tanggalSelesai)) {
        _errorMessage = 'Tanggal mulai tidak boleh setelah tanggal selesai';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (batasPendaftaran.isAfter(tanggalMulai)) {
        _errorMessage = 'Batas pendaftaran tidak boleh setelah tanggal mulai';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newEvent = await _supabaseService.createEvent(
        nama: nama,
        deskripsi: deskripsi,
        tipe: tipe,
        lokasi: lokasi,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        batasPendaftaran: batasPendaftaran,
        kapasitas: kapasitas,
        adminId: adminId,
      );

      if (newEvent != null) {
        _events.add(newEvent);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal membuat event';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update event
  Future<bool> updateEvent({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validation
      if (nama.isEmpty || deskripsi.isEmpty || lokasi.isEmpty) {
        _errorMessage = 'Semua field wajib diisi';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (kapasitas <= 0) {
        _errorMessage = 'Kapasitas harus lebih dari 0';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (tanggalMulai.isAfter(tanggalSelesai)) {
        _errorMessage = 'Tanggal mulai tidak boleh setelah tanggal selesai';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (batasPendaftaran.isAfter(tanggalMulai)) {
        _errorMessage = 'Batas pendaftaran tidak boleh setelah tanggal mulai';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedEvent = await _supabaseService.updateEvent(
        eventId: eventId,
        nama: nama,
        deskripsi: deskripsi,
        tipe: tipe,
        lokasi: lokasi,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        batasPendaftaran: batasPendaftaran,
        kapasitas: kapasitas,
      );

      if (updatedEvent != null) {
        final index = _events.indexWhere((e) => e.id == eventId);
        if (index != -1) {
          _events[index] = updatedEvent;
        }
        _selectedEvent = updatedEvent;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal mengupdate event';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get event by ID
  Future<void> getEventById(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedEvent = await _supabaseService.getEventById(eventId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat detail event: $e';
      notifyListeners();
    }
  }

  /// Close event registration
  Future<bool> closeEventRegistration(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success =
          await _supabaseService.closeEventRegistration(eventId);

      if (success) {
        final index = _events.indexWhere((e) => e.id == eventId);
        if (index != -1) {
          // Update event in list
          final updatedEvent = await _supabaseService.getEventById(eventId);
          if (updatedEvent != null) {
            _events[index] = updatedEvent;
          }
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal menutup pendaftaran';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // ==================== PARTICIPANT OPERATIONS ====================

  /// Get event participants
  Future<void> getEventParticipants(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _eventParticipants =
          await _supabaseService.getEventParticipants(eventId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat peserta: $e';
      notifyListeners();
    }
  }

  /// Get participant count
  int getParticipantCount(String eventId) {
    final event = _events.firstWhere(
      (e) => e.id == eventId,
      orElse: () => Event(
        id: '',
        nama: '',
        deskripsi: '',
        tipe: '',
        lokasi: '',
        tanggalMulai: DateTime.now(),
        tanggalSelesai: DateTime.now(),
        batasPendaftaran: DateTime.now(),
        kapasitas: 0,
        terdaftar: 0,
        pendaftaranDitutup: false,
        adminId: '',
        createdAt: DateTime.now(),
      ),
    );
    return event.terdaftar;
  }

  /// Get available slots
  int getAvailableSlots(String eventId) {
    final event = _events.firstWhere(
      (e) => e.id == eventId,
      orElse: () => Event(
        id: '',
        nama: '',
        deskripsi: '',
        tipe: '',
        lokasi: '',
        tanggalMulai: DateTime.now(),
        tanggalSelesai: DateTime.now(),
        batasPendaftaran: DateTime.now(),
        kapasitas: 0,
        terdaftar: 0,
        pendaftaranDitutup: false,
        adminId: '',
        createdAt: DateTime.now(),
      ),
    );
    return event.kapasitas - event.terdaftar;
  }

  // ==================== UTILITY METHODS ====================

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _events = [];
    _selectedEvent = null;
    _eventParticipants = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Format date
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Is registration open?
  bool isRegistrationOpen(Event event) {
    return !event.pendaftaranDitutup &&
        DateTime.now().isBefore(event.batasPendaftaran) &&
        event.terdaftar < event.kapasitas;
  }

  // ==================== USER REGISTRATION OPERATIONS ====================

  /// Register user for event
  Future<bool> registerForEvent({
    required String eventId,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if event is still accepting registrations
      final event = await _supabaseService.getEventById(eventId);
      if (event == null) {
        _errorMessage = 'Event tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (event.pendaftaranDitutup) {
        _errorMessage = 'Pendaftaran untuk event ini sudah ditutup';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (event.terdaftar >= event.kapasitas) {
        _errorMessage = 'Event ini sudah penuh';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (DateTime.now().isAfter(event.batasPendaftaran)) {
        _errorMessage = 'Batas pendaftaran untuk event ini sudah berlalu';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Register user
      final success = await _supabaseService.registerForEvent(
        eventId: eventId,
        userId: userId,
      );

      if (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal mendaftar untuk event';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get user registrations
  Future<void> getUserRegistrations(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userRegistrations =
          await _supabaseService.getUserRegistrations(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat registrasi: $e';
      notifyListeners();
    }
  }

  /// Get user tickets
  Future<void> getUserTickets(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userTickets = await _supabaseService.getUserTickets(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat tiket: $e';
      notifyListeners();
    }
  }

  /// Get specific ticket by ID
  Future<void> getTicketById(String ticketId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedTicket = await _supabaseService.getTicketById(ticketId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat detail tiket: $e';
      notifyListeners();
    }
  }

  // ==================== UTILITY METHODS ====================