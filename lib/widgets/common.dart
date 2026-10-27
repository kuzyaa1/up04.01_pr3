import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const compactWidth = 900.0;

/// Keeps URL-driven filters in sync without losing focus while typing.
class QueryTextField extends StatefulWidget {
  final String? value;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  const QueryTextField(
      {super.key,
      this.value,
      required this.decoration,
      this.keyboardType,
      this.onChanged,
      this.onFieldSubmitted});
  @override
  State<QueryTextField> createState() => _QueryTextFieldState();
}

class _QueryTextFieldState extends State<QueryTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value ?? '');
  @override
  void didUpdateWidget(covariant QueryTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != (widget.value ?? '')) {
      final text = widget.value ?? '';
      _controller.value = TextEditingValue(
          text: text, selection: TextSelection.collapsed(offset: text.length));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
      controller: _controller,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted);
}

class AppScaffold extends StatelessWidget {
  final String title;
  final int index;
  final Widget child;
  final List<Widget> actions;
  const AppScaffold(
      {super.key,
      required this.title,
      required this.index,
      required this.child,
      this.actions = const []});
  @override
  Widget build(BuildContext context) {
    final destinations = [
      (Icons.event_available, 'Бронирования', '/bookings'),
      (Icons.meeting_room, 'Залы', '/halls'),
      (Icons.camera_alt, 'Фотографы', '/photographers'),
      (Icons.people, 'Клиенты', '/clients'),
      (Icons.lightbulb_outline, 'Оборудование', '/equipment'),
    ];
    final compact = MediaQuery.sizeOf(context).width < compactWidth;
    final app = AppBar(title: Text(title), actions: actions);
    if (compact) {
      return Scaffold(
          appBar: app,
          body: child,
          bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => context.go(destinations[i].$3),
              destinations: [
                for (final d in destinations)
                  NavigationDestination(icon: Icon(d.$1), label: d.$2)
              ]));
    }
    return Scaffold(
        appBar: app,
        body: Row(children: [
          NavigationRail(
              selectedIndex: index,
              extended: MediaQuery.sizeOf(context).width >= 1200,
              onDestinationSelected: (i) => context.go(destinations[i].$3),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(icon: Icon(d.$1), label: Text(d.$2))
              ]),
          const VerticalDivider(width: 1),
          Expanded(child: child)
        ]));
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class StatusView extends StatelessWidget {
  final String text;
  final bool error;
  final VoidCallback? retry;
  final IconData? icon;

  const StatusView(
      {super.key,
      required this.text,
      this.error = false,
      this.retry,
      this.icon});
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon ?? (error ? Icons.error_outline : Icons.search_off),
            size: 48,
            color: error ? Theme.of(context).colorScheme.error : null),
        const SizedBox(height: 12),
        Text(text, textAlign: TextAlign.center),
        if (retry != null)
          Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton(
                  onPressed: retry, child: const Text('Повторить')))
      ]));
}

class Pager extends StatelessWidget {
  final int page, totalPages, total, size;
  final ValueChanged<int> onPage, onSize;
  const Pager(
      {super.key,
      required this.page,
      required this.totalPages,
      required this.total,
      required this.size,
      required this.onPage,
      required this.onSize});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Всего: $total'),
            DropdownButton<int>(
                value: size,
                items: [10, 25, 50]
                    .map((x) => DropdownMenuItem(value: x, child: Text('$x')))
                    .toList(),
                onChanged: (x) {
                  if (x != null) onSize(x);
                }),
            IconButton(
                onPressed: page > 1 ? () => onPage(1) : null,
                icon: const Icon(Icons.first_page)),
            IconButton(
                onPressed: page > 1 ? () => onPage(page - 1) : null,
                icon: const Icon(Icons.chevron_left)),
            Text('$page / $totalPages'),
            IconButton(
                onPressed: page < totalPages ? () => onPage(page + 1) : null,
                icon: const Icon(Icons.chevron_right)),
            IconButton(
                onPressed: page < totalPages ? () => onPage(totalPages) : null,
                icon: const Icon(Icons.last_page))
          ]));
}

Future<bool> confirm(BuildContext context, String text,
        {bool hard = false, String? title}) async =>
    (await showDialog<bool>(
        context: context,
        builder: (x) => AlertDialog(
                title: Text(title ??
                    (hard ? 'Физическое удаление' : 'Логическое удаление')),
                content: Text(text),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(x, false),
                      child: const Text('Отмена')),
                  FilledButton(
                      onPressed: () => Navigator.pop(x, true),
                      child: Text(hard ? 'Стереть' : 'Удалить'))
                ]))) ??
    false;
void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
}
