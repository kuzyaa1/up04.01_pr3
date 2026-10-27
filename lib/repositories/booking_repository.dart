import '../models/booking.dart';
import '../models/booking_query.dart';
import '../models/page_result.dart';

abstract interface class BookingRepository {
  Future<PageResult<Booking>> find(BookingQuery query);
  Future<Booking?> findById(int id);
  Future<List<Booking>> all({bool includeDeleted = false});
  Future<Booking> save(Booking booking);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> softDeleteMany(List<int> ids);
  Future<int> hardDeleteMany(List<int> ids);
  Future<int> countForHall(int hallId);
  Future<int> countForClient(int clientId);
  Future<int> countForPhotographer(int photographerId);
  Future<List<String>> shootingTypes();
}
