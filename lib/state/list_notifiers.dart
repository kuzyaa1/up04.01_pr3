import '../models/hall_query.dart';
import '../models/page_result.dart';
import '../models/photographer_query.dart';
import '../models/studio_hall.dart';
import '../models/photographer.dart';
import '../repositories/hall_repository.dart';
import '../repositories/photographer_repository.dart';
import 'list_notifier.dart';

class HallListNotifier extends ListNotifier<StudioHall> {
  HallListNotifier(this._repo);
  final HallRepository _repo;
  HallQuery _query = const HallQuery();
  HallQuery get query => _query;
  @override
  Future<PageResult<StudioHall>> fetch() => _repo.find(_query);
  @override
  Future<void> applyQuery(Object query) async {
    _query = query as HallQuery;
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

class PhotographerListNotifier extends ListNotifier<Photographer> {
  PhotographerListNotifier(this._repo);
  final PhotographerRepository _repo;
  PhotographerQuery _query = const PhotographerQuery();
  PhotographerQuery get query => _query;
  @override
  Future<PageResult<Photographer>> fetch() => _repo.find(_query);
  @override
  Future<void> applyQuery(Object query) async {
    _query = query as PhotographerQuery;
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
