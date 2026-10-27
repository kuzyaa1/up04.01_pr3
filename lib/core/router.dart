import 'package:go_router/go_router.dart';
import '../widgets/dirty_guard.dart';
import '../screens/entity_detail_screen.dart';
import '../models/booking_query.dart';
import '../models/client_query.dart';
import '../models/equipment_query.dart';
import '../models/hall_query.dart';
import '../models/photographer_query.dart';
import '../screens/booking_form_screen.dart';
import '../screens/booking_list_screen.dart';
import '../screens/client_form_screen.dart';
import '../screens/client_list_screen.dart';
import '../screens/equipment_form_screen.dart';
import '../screens/equipment_list_screen.dart';
import '../screens/hall_form_screen.dart';
import '../screens/hall_list_screen.dart';
import '../screens/home_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/photographer_form_screen.dart';
import '../screens/photographer_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
        path: '/halls',
        builder: (_, s) => HallListScreen(query: HallQuery.fromUri(s.uri))),
    GoRoute(
        path: '/halls/new',
        onExit: (_, __) => DirtyGuard.mayLeave(),
        builder: (_, __) => const HallFormScreen()),
    GoRoute(
        path: '/halls/:id/edit',
        onExit: (_, __) => DirtyGuard.mayLeave(),
        builder: (_, s) => HallFormScreen(
            id: int.tryParse(s.pathParameters['id'] ?? '') ?? -1)),
    GoRoute(
        path: '/photographers',
        builder: (_, s) =>
            PhotographerListScreen(query: PhotographerQuery.fromUri(s.uri))),
    GoRoute(
        path: '/photographers/new',
        onExit: (_, __) => DirtyGuard.mayLeave(),
        builder: (_, __) => const PhotographerFormScreen()),
    GoRoute(
        path: '/photographers/:id/edit',
        onExit: (_, __) => DirtyGuard.mayLeave(),
        builder: (_, s) => PhotographerFormScreen(
            id: int.tryParse(s.pathParameters['id'] ?? '') ?? -1)),
    GoRoute(
        path: '/bookings',
        builder: (_, s) =>
            BookingListScreen(query: BookingQuery.fromUri(s.uri))),
    GoRoute(
        path: '/bookings/new',
        onExit: (_, __) => DirtyGuard.mayLeave(),
        builder: (_, __) => const BookingFormScreen()),
    GoRoute(
        path: '/bookings/:id/edit',
        onExit: (_, __) => DirtyGuard.mayLeave(),
        builder: (_, s) => BookingFormScreen(
            id: int.tryParse(s.pathParameters['id'] ?? '') ?? -1)),
    GoRoute(
        path: '/clients',
        builder: (_, s) => ClientListScreen(query: ClientQuery.fromUri(s.uri))),
    GoRoute(
        path: '/clients/new',
        onExit: (_, __) => DirtyGuard.mayLeave(),
        builder: (_, __) => const ClientFormScreen()),
    GoRoute(
        path: '/clients/:id/edit',
        onExit: (_, __) => DirtyGuard.mayLeave(),
        builder: (_, s) => ClientFormScreen(
            id: int.tryParse(s.pathParameters['id'] ?? '') ?? -1)),
    GoRoute(
        path: '/equipment',
        builder: (_, s) =>
            EquipmentListScreen(query: EquipmentQuery.fromUri(s.uri))),
    GoRoute(
        path: '/equipment/new',
        onExit: (_, __) => DirtyGuard.mayLeave(),
        builder: (_, __) => const EquipmentFormScreen()),
    GoRoute(
        path: '/equipment/:id/edit',
        onExit: (_, __) => DirtyGuard.mayLeave(),
        builder: (_, s) => EquipmentFormScreen(
            id: int.tryParse(s.pathParameters['id'] ?? '') ?? -1)),
    for (final collection in [
      'halls',
      'photographers',
      'bookings',
      'clients',
      'equipment'
    ])
      GoRoute(
          path: '/$collection/:id',
          builder: (_, state) => EntityDetailScreen(
              collection: collection,
              id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1)),
  ],
  errorBuilder: (_, s) => NotFoundScreen(location: s.uri.toString()),
);
