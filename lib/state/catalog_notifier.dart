import 'package:flutter/foundation.dart';
import '../models/photographer.dart';
import '../models/studio_hall.dart';
import '../models/client.dart';
import '../repositories/hall_repository.dart';
import '../repositories/photographer_repository.dart';
import '../repositories/client_repository.dart';
import '../repositories/equipment_repository.dart';
import '../repositories/booking_repository.dart';

class CatalogNotifier extends ChangeNotifier {
  CatalogNotifier({
    required HallRepository halls,
    required PhotographerRepository photographers,
    required ClientRepository clients,
    required BookingRepository bookings,
    required EquipmentRepository equipment,
  })  : _halls = halls,
        _photographers = photographers,
        _clients = clients,
        _bookings = bookings,
        _equipment = equipment;
  final HallRepository _halls;
  final PhotographerRepository _photographers;
  final ClientRepository _clients;
  final BookingRepository _bookings;
  final EquipmentRepository _equipment;
  List<StudioHall> _hallOptions = [];
  List<Photographer> _photographerOptions = [];
  List<Client> _clientOptions = [];
  List<String> _shootingTypes = [];
  bool _loaded = false;
  List<StudioHall> get halls => List.unmodifiable(_hallOptions);
  List<Photographer> get photographers =>
      List.unmodifiable(_photographerOptions);
  List<Client> get clients => List.unmodifiable(_clientOptions);
  List<String> get shootingTypes => List.unmodifiable(_shootingTypes);
  bool get loaded => _loaded;
  Future<void> load() async {
    _hallOptions = await _halls.all();
    _photographerOptions = await _photographers.all();
    _clientOptions = await _clients.all();
    _shootingTypes = await _bookings.shootingTypes();
    _loaded = true;
    notifyListeners();
  }

  String hallName(int id) {
    for (final hall in _hallOptions) {
      if (hall.id == id) return hall.name;
    }
    return 'Зал #$id';
  }

  String photographerName(int id) {
    for (final item in _photographerOptions) {
      if (item.id == id) return item.fullName;
    }
    return 'Фотограф #$id';
  }

  String clientName(int id) {
    for (final client in _clientOptions) {
      if (client.id == id) return client.name;
    }
    return 'Клиент #$id';
  }

  List<String> get hallStyles {
    final values = _hallOptions
        .map((hall) => hall.style)
        .where((style) => style.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  List<String> get specializations {
    final values = _photographerOptions
        .map((item) => item.specialization)
        .where((text) => text.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  Future<List<String>> equipmentCategories() async {
    final values = (await _equipment.all())
        .where((item) => !item.isDeleted)
        .map((item) => item.category)
        .where((text) => text.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return values;
  }
}
