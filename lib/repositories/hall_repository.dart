import '../models/hall_query.dart';
import '../models/page_result.dart';
import '../models/studio_hall.dart';

abstract interface class HallRepository {
  Future<PageResult<StudioHall>> find(HallQuery query);
  Future<StudioHall?> findById(int id);
  Future<List<StudioHall>> all({bool includeDeleted = false});
  Future<StudioHall> save(StudioHall hall);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> softDeleteMany(List<int> ids);
  Future<int> hardDeleteMany(List<int> ids);
  Future<int> countBookings(int id);
  Future<int> countEquipment(int id);
}
