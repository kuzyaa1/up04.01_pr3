import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final entities = [
      (
        Icons.event_available,
        'Бронирования',
        '/bookings',
        'Центральная сущность: связь с залами, клиентами и фотографами'
      ),
      (Icons.meeting_room, 'Залы', '/halls', 'Один ко многим с бронированиями'),
      (
        Icons.camera_alt,
        'Фотографы',
        '/photographers',
        'Многие ко многим с залами и бронированиями'
      ),
      (Icons.people, 'Клиенты', '/clients', 'Один к одному с абонементом'),
      (
        Icons.lightbulb_outline,
        'Оборудование',
        '/equipment',
        'Многие к одному с залами'
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('FocusFrames — фотостудия')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Система бронирования фотостудии',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                const Text(
                  'Пять сущностей со всеми тремя типами связей: формы создания '
                  'и редактирования, поиск, фильтрация, сортировка, '
                  'постраничный вывод и логическое с физическое удаление.',
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final entity in entities)
                      SizedBox(
                        width: 250,
                        child: Card(
                          child: InkWell(
                            onTap: () => context.go(entity.$3),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(entity.$1, size: 28),
                                  const SizedBox(height: 8),
                                  Text(entity.$2,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 4),
                                  Text(entity.$4,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
