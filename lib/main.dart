import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router.dart';
import 'core/storage.dart';
import 'repositories/photo_studio_repositories.dart';
import 'repositories/booking_repository.dart';
import 'repositories/client_repository.dart';
import 'repositories/equipment_repository.dart';
import 'repositories/hall_repository.dart';
import 'repositories/photographer_repository.dart';
import 'state/catalog_notifier.dart';
import 'state/catalog_notifiers.dart';
import 'state/list_notifiers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final preferences = await SharedPreferences.getInstance();
  final repositories = PhotoStudioRepositories(preferences);
  await repositories.clients.persist();
  await repositories.equipment.persist();
  await repositories.bookings.persist();
  final migrationNotice = VersionedStore.takeNotice(preferences);
  runApp(MultiProvider(
    providers: [
      Provider<HallRepository>.value(value: repositories.halls),
      Provider<PhotographerRepository>.value(value: repositories.photographers),
      Provider<BookingRepository>.value(value: repositories.bookings),
      Provider<ClientRepository>.value(value: repositories.clients),
      Provider<EquipmentRepository>.value(value: repositories.equipment),
      ChangeNotifierProvider(
          create: (c) => HallListNotifier(c.read<HallRepository>())
            ..onMutation = () => c.read<CatalogNotifier>().load()),
      ChangeNotifierProvider(
          create: (c) =>
              PhotographerListNotifier(c.read<PhotographerRepository>())
                ..onMutation = () => c.read<CatalogNotifier>().load()),
      ChangeNotifierProvider(
          create: (c) => BookingListNotifier(c.read<BookingRepository>())
            ..onMutation = () => c.read<CatalogNotifier>().load()),
      ChangeNotifierProvider(
          create: (c) => ClientListNotifier(c.read<ClientRepository>())
            ..onMutation = () => c.read<CatalogNotifier>().load()),
      ChangeNotifierProvider(
          create: (c) => EquipmentListNotifier(c.read<EquipmentRepository>())
            ..onMutation = () => c.read<CatalogNotifier>().load()),
      ChangeNotifierProvider(
        create: (c) => CatalogNotifier(
          halls: c.read<HallRepository>(),
          photographers: c.read<PhotographerRepository>(),
          clients: c.read<ClientRepository>(),
          bookings: c.read<BookingRepository>(),
          equipment: c.read<EquipmentRepository>(),
        )..load(),
      ),
    ],
    child: PhotoStudioApp(notice: migrationNotice),
  ));
}

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

class PhotoStudioApp extends StatelessWidget {
  final String? notice;
  const PhotoStudioApp({super.key, this.notice});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'FocusFrames',
        scaffoldMessengerKey: _messengerKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
        builder: (context, child) {
          if (notice == null) return child ?? const SizedBox.shrink();
          return MigrationNoticeHost(message: notice!, child: child!);
        },
      );
}

class MigrationNoticeHost extends StatefulWidget {
  final String message;
  final Widget child;
  const MigrationNoticeHost(
      {super.key, required this.message, required this.child});
  @override
  State<MigrationNoticeHost> createState() => _MigrationNoticeHostState();
}

class _MigrationNoticeHostState extends State<MigrationNoticeHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = _messengerKey.currentState;
      messenger?.showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.storage, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.message)),
        ]),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
      ));
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
