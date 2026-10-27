import '../models/booking.dart';
import '../models/booking_query.dart';
import '../models/client.dart';
import '../models/client_query.dart';
import '../models/equipment.dart';
import '../models/equipment_query.dart';
import '../models/page_result.dart';
import '../repositories/booking_repository.dart';
import '../repositories/client_repository.dart';
import '../repositories/equipment_repository.dart';
import 'list_notifier.dart';

class BookingListNotifier extends ListNotifier<Booking> {
  BookingListNotifier(this._repo);
  final BookingRepository _repo;
  BookingQuery _query = const BookingQuery();
  BookingQuery get query => _query;
  @override
  Future<PageResult<Booking>> fetch() => _repo.find(_query);
  @override
  Future<void> applyQuery(Object query) async {
    _query = query as BookingQuery;
    clearSelection();
    await load();
  }

  @override
  Future<void> softDelete(int id) => mutate(() async {
        await _repo.softDelete(id);
        await load();
      });
  @override
  Future<void> hardDelete(int id) => mutate(() async {
        await _repo.hardDelete(id);
        await load();
      });
  @override
  Future<void> restore(int id) => mutate(() async {
        await _repo.restore(id);
        await load();
      });
  @override
  Future<void> deleteSelected() => mutate(() async {
        await _repo.softDeleteMany(selectedIds);
        clearSelection();
        await load();
      });
  @override
  Future<void> eraseSelected() => mutate(() async {
        await _repo.hardDeleteMany(selectedIds);
        clearSelection();
        await load();
      });
}

class ClientListNotifier extends ListNotifier<Client> {
  ClientListNotifier(this._repo);
  final ClientRepository _repo;
  ClientQuery _query = const ClientQuery();
  ClientQuery get query => _query;
  @override
  Future<PageResult<Client>> fetch() => _repo.find(_query);
  @override
  Future<void> applyQuery(Object query) async {
    _query = query as ClientQuery;
    clearSelection();
    await load();
  }

  @override
  Future<void> softDelete(int id) => mutate(() async {
        await _repo.softDelete(id);
        await load();
      });
  @override
  Future<void> hardDelete(int id) => mutate(() async {
        await _repo.hardDelete(id);
        await load();
      });
  @override
  Future<void> restore(int id) => mutate(() async {
        await _repo.restore(id);
        await load();
      });
  @override
  Future<void> deleteSelected() => mutate(() async {
        await _repo.softDeleteMany(selectedIds);
        clearSelection();
        await load();
      });
  @override
  Future<void> eraseSelected() => mutate(() async {
        await _repo.hardDeleteMany(selectedIds);
        clearSelection();
        await load();
      });
}

class EquipmentListNotifier extends ListNotifier<Equipment> {
  EquipmentListNotifier(this._repo);
  final EquipmentRepository _repo;
  EquipmentQuery _query = const EquipmentQuery();
  EquipmentQuery get query => _query;
  @override
  Future<PageResult<Equipment>> fetch() => _repo.find(_query);
  @override
  Future<void> applyQuery(Object query) async {
    _query = query as EquipmentQuery;
    clearSelection();
    await load();
  }

  @override
  Future<void> softDelete(int id) => mutate(() async {
        await _repo.softDelete(id);
        await load();
      });

  @override
  Future<void> hardDelete(int id) => mutate(() async {
        await _repo.hardDelete(id);
        await load();
      });
  @override
  Future<void> restore(int id) => mutate(() async {
        await _repo.restore(id);
        await load();
      });
  @override
  Future<void> deleteSelected() => mutate(() async {
        await _repo.softDeleteMany(selectedIds);
        clearSelection();
        await load();
      });
  @override
  Future<void> eraseSelected() => mutate(() async {
        await _repo.hardDeleteMany(selectedIds);
        clearSelection();
        await load();
      });
}
