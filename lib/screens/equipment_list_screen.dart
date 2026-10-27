import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/equipment.dart';
import '../models/equipment_query.dart';
import '../state/catalog_notifier.dart';
import '../state/catalog_notifiers.dart';
import '../state/list_notifier.dart';
import '../widgets/common.dart';
import '../widgets/entity_table.dart';

class EquipmentListScreen extends StatefulWidget {
  final EquipmentQuery query;
  const EquipmentListScreen({super.key, required this.query});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  Timer? _timer;
  List<String> _categories = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _sync();
      final repository = context.read<CatalogNotifier>();
      final categories = await repository.equipmentCategories();
      if (mounted) setState(() => _categories = categories);
    });
  }

  @override
  void didUpdateWidget(covariant EquipmentListScreen old) {
    super.didUpdateWidget(old);
    if (old.query.toQueryParameters().toString() !=
        widget.query.toQueryParameters().toString()) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _sync() =>
      context.read<EquipmentListNotifier>().applyQuery(widget.query);
  void _go(EquipmentQuery query) {
    final parameters = query.toQueryParameters();
    context.go(parameters.isEmpty
        ? '/equipment'
        : Uri(path: '/equipment', queryParameters: parameters).toString());
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<EquipmentListNotifier>();
    final catalog = context.watch<CatalogNotifier>();
    return AppScaffold(
      title: 'Оборудование',
      index: 4,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
                onPressed: () => context.go('/equipment/new'),
                icon: const Icon(Icons.add),
                label: const Text('Новое оборудование')),
          ),
        ),
        _filters(notifier, catalog),
        if (notifier.hasSelection) _selection(notifier),
        Expanded(child: _body(notifier, catalog)),
        if (notifier.status == LoadStatus.success && notifier.result.total > 0)
          Pager(
              page: notifier.result.page,
              totalPages: notifier.result.totalPages,
              total: notifier.result.total,
              size: notifier.result.size,
              onPage: (value) => _go(notifier.query.copyWith(page: value)),
              onSize: (value) => _go(notifier.query.copyWith(size: value))),
      ]),
    );
  }

  Widget _filters(EquipmentListNotifier notifier, CatalogNotifier catalog) {
    final query = widget.query;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(spacing: 10, runSpacing: 10, children: [
        SizedBox(
            width: 260,
            child: QueryTextField(
                value: query.search,
                decoration: const InputDecoration(
                    labelText: 'Поиск: название, категория, производитель',
                    border: OutlineInputBorder()),
                onChanged: (value) {
                  _timer?.cancel();
                  _timer = Timer(const Duration(milliseconds: 350),
                      () => _go(query.copyWith(search: value)));
                })),
        SizedBox(
            width: 200,
            child: DropdownButtonFormField<String?>(
                value: _categories.contains(query.category)
                    ? query.category
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: 'Категория', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('Все категории')),
                  for (final value in _categories)
                    DropdownMenuItem<String?>(value: value, child: Text(value)),
                ],
                onChanged: (value) => _go(query.copyWith(category: value)))),
        SizedBox(
            width: 220,
            child: DropdownButtonFormField<int?>(
                value: catalog.halls.any((h) => h.id == query.hallId)
                    ? query.hallId
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: 'Зал', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('Все залы')),
                  for (final hall in catalog.halls)
                    DropdownMenuItem<int?>(
                        value: hall.id, child: Text(hall.name)),
                ],
                onChanged: (value) => _go(query.copyWith(hallId: value)))),
        _numberField('Кол-во от', query.quantityFrom,
            (value) => _go(query.copyWith(quantityFrom: value))),
        _numberField('Кол-во до', query.quantityTo,
            (value) => _go(query.copyWith(quantityTo: value))),
        _numberField('Цена от', query.priceFrom,
            (value) => _go(query.copyWith(priceFrom: value))),
        _numberField('Цена до', query.priceTo,
            (value) => _go(query.copyWith(priceTo: value))),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Switch(
              value: query.includeDeleted,
              onChanged: (value) => _go(query.copyWith(includeDeleted: value))),
          const Text('Удалённые')
        ]),
        TextButton(
            onPressed: query.hasActiveFilters
                ? () => _go(EquipmentQuery(
                    size: query.size,
                    sortField: query.sortField,
                    sortAscending: query.sortAscending))
                : null,
            child: const Text('Сбросить')),
      ]),
    );
  }

  Widget _numberField(String label, int? value, ValueChanged<int?> onChanged) =>
      SizedBox(
          width: 140,
          child: QueryTextField(
              value: value?.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: label, border: OutlineInputBorder()),
              onFieldSubmitted: (text) => onChanged(int.tryParse(text))));
  Widget _selection(EquipmentListNotifier notifier) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Wrap(spacing: 8, children: [
          Text('Выбрано: ${notifier.selected.length}'),
          FilledButton(
              onPressed: () async {
                if (await confirm(context, 'Удалить выбранное оборудование?')) {
                  await notifier.deleteSelected();
                }
              },
              child: const Text('Удалить')),
          OutlinedButton(
              onPressed: () async {
                if (await confirm(context, 'Стереть выбранное оборудование?',
                    hard: true)) {
                  await notifier.eraseSelected();
                }
              },
              child: const Text('Стереть навсегда')),
          TextButton(
              onPressed: notifier.clearSelection,
              child: const Text('Снять выделение')),
        ]),
      );
  Widget _body(EquipmentListNotifier notifier, CatalogNotifier catalog) {
    if (notifier.status == LoadStatus.idle ||
        notifier.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifier.status == LoadStatus.error) {
      return StatusView(
          text: notifier.error ?? 'Ошибка загрузки',
          error: true,
          retry: notifier.load);
    }
    if (notifier.result.items.isEmpty) {
      return const StatusView(text: 'Оборудование не найдено.');
    }
    if (MediaQuery.sizeOf(context).width < compactWidth) {
      return ListView(children: [
        for (final item in notifier.result.items) _card(item, catalog)
      ]);
    }
    return EntityTable<Equipment>(
      items: notifier.result.items,
      id: (item) => item.id,
      selected: notifier.selected,
      toggle: notifier.toggle,
      sort: notifier.query.sortField,
      asc: notifier.query.sortAscending,
      onSort: (field) => _go(notifier.query.copyWith(
          sortField: field,
          sortAscending: field == notifier.query.sortField
              ? !notifier.query.sortAscending
              : true)),
      columns: [
        (
          'Название',
          'name',
          (item) => Text('${item.name}${item.isDeleted ? ' (удалено)' : ''}')
        ),
        ('Категория', 'category', (item) => Text(item.category)),
        ('Производитель', null, (item) => Text(item.manufacturer)),
        ('Зал', 'hall', (item) => Text(catalog.hallName(item.hallId))),
        ('Кол-во', 'quantity', (item) => Text('${item.quantity}')),
        ('Цена/день', 'pricePerDay', (item) => Text('${item.pricePerDay} ₽')),
      ],
      actions: (item) => _actions(item),
    );
  }

  Widget _card(Equipment item, CatalogNotifier catalog) => Card(
        child: ListTile(
          leading: Checkbox(
              value: context
                  .watch<EquipmentListNotifier>()
                  .selected
                  .contains(item.id),
              onChanged: (_) =>
                  context.read<EquipmentListNotifier>().toggle(item.id)),
          title: Text(item.name),
          subtitle: Text('${item.category} · ${catalog.hallName(item.hallId)}\n'
              '${item.quantity} шт. · ${item.pricePerDay} ₽/день'
              '${item.isDeleted ? ' · удалено' : ''}'),
          isThreeLine: true,
          trailing: Wrap(children: _actions(item)),
        ),
      );
  List<Widget> _actions(Equipment item) => [
        IconButton(
            tooltip: 'Открыть карточку',
            onPressed: () => context.go('/equipment/${item.id}'),
            icon: const Icon(Icons.visibility_outlined)),
        IconButton(
            tooltip: 'Редактировать',
            onPressed: () => context.go('/equipment/${item.id}/edit'),
            icon: const Icon(Icons.edit_outlined)),
        if (item.isDeleted)
          IconButton(
              tooltip: 'Восстановить',
              onPressed: () =>
                  context.read<EquipmentListNotifier>().restore(item.id),
              icon: const Icon(Icons.restore))
        else
          IconButton(
              tooltip: 'Удалить',
              onPressed: () => _delete(item, hard: false),
              icon: const Icon(Icons.delete_outline)),
        IconButton(
            tooltip: 'Стереть навсегда',
            onPressed: () => _delete(item, hard: true),
            icon: const Icon(Icons.delete_forever)),
      ];
  Future<void> _delete(Equipment item, {required bool hard}) async {
    final equipment = context.read<EquipmentListNotifier>();
    final catalog = context.read<CatalogNotifier>();
    if (!mounted) return;
    if (await confirm(
        context,
        hard
            ? 'Стереть оборудование «${item.name}»?'
            : 'Удалить оборудование «${item.name}»?',
        hard: hard)) {
      if (hard) {
        await equipment.hardDelete(item.id);
      } else {
        await equipment.softDelete(item.id);
      }
      await catalog.load();
    }
  }
}
