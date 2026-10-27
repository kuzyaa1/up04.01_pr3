import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/errors.dart';
import '../core/validators.dart';
import '../models/photographer.dart';
import '../repositories/photographer_repository.dart';
import '../state/catalog_notifier.dart';
import '../widgets/common.dart';
import '../widgets/dirty_guard.dart';
import '../widgets/entity_form.dart';

class PhotographerFormScreen extends StatefulWidget {
  final int? id;
  const PhotographerFormScreen({super.key, this.id});
  bool get isEditing => id != null;
  @override
  State<PhotographerFormScreen> createState() => _PhotographerFormScreenState();
}

class _PhotographerFormScreenState extends State<PhotographerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _entityFormKey = GlobalKey<EntityFormState>();
  Photographer? _photographer;
  final Map<String, String?> _serverErrors = {};
  bool _loading = true;
  bool _dirty = false;
  int _revision = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final options = context.read<CatalogNotifier>();
    if (!options.loaded) await options.load();
    if (!mounted) return;
    Photographer? photographer;
    if (widget.id != null) {
      photographer =
          await context.read<PhotographerRepository>().findById(widget.id!);
    }
    if (!mounted) return;
    setState(() {
      _photographer = photographer;
      _loading = false;
    });
  }

  List<FieldSpec> _fields(CatalogNotifier catalog) {
    final item = _photographer;
    return [
      FieldSpec(
        name: 'lastName',
        label: 'Фамилия',
        initialValue: item?.lastName,
        validators: [V.required(), V.length(min: 2, max: 50)],
        serverError: _serverErrors['lastName'],
        width: 300,
      ),
      FieldSpec(
        name: 'firstName',
        label: 'Имя',
        initialValue: item?.firstName,
        validators: [V.required(), V.length(min: 2, max: 50)],
        width: 300,
      ),
      FieldSpec(
        name: 'specialization',
        label: 'Специализация',
        type: catalog.specializations.isEmpty
            ? FieldType.text
            : FieldType.dropdownText,
        initialValue: item?.specialization,
        hint: catalog.specializations.isEmpty ? 'Специализация' : null,
        textOptions: [
          for (final text in catalog.specializations)
            TextDropdownEntry(text, text),
        ],
        validators: [V.required(), V.length(min: 3, max: 40)],
        width: 300,
      ),
      FieldSpec(
        name: 'experienceYears',
        label: 'Стаж, лет',
        type: FieldType.number,
        initialValue: item?.experienceYears ?? 1,
        validators: [V.integer(min: 0, max: 60, label: 'Стаж')],
        width: 200,
      ),
      FieldSpec(
        name: 'hourlyRate',
        label: 'Ставка, ₽/час',
        type: FieldType.number,
        initialValue: item?.hourlyRate ?? 3000,
        validators: [V.integer(min: 500, max: 100000, label: 'Ставка')],
        width: 220,
      ),
      FieldSpec(
        name: 'hallIds',
        serverError: _serverErrors['hallIds'],
        label: 'Работает в залах',
        type: FieldType.multiselect,
        initialValue: item?.hallIds ?? const [],
        hint: 'Связь «многие ко многим» с залами',
        isWideList: true,
        options: [
          for (final hall in catalog.halls) DropdownEntry(hall.id, hall.name),
        ],
        validators: [
          (value) =>
              value == null || value == '' ? 'Выберите хотя бы один зал' : null
        ],
      ),
      FieldSpec(
        name: 'bio',
        label: 'О себе',
        type: FieldType.multiline,
        initialValue: item?.bio ?? '',
        hint: 'Необязательно',
        validators: [V.length(max: 500)],
      ),
    ];
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final form = _entityFormKey.currentState;
    if (form == null) return;
    try {
      await context.read<PhotographerRepository>().save(Photographer(
            id: _photographer?.id ?? 0,
            lastName: form.string('lastName'),
            firstName: form.string('firstName'),
            specialization: form.string('specialization'),
            bio: form.string('bio'),
            experienceYears: form.number('experienceYears'),
            hourlyRate: form.number('hourlyRate'),
            hallIds: form.selection('hallIds'),
            bookingIds: _photographer?.bookingIds ?? const [],
            deletedAt: _photographer?.deletedAt,
          ));
      _dirty = false;
      if (!mounted) return;
      await context.read<CatalogNotifier>().load();
      if (mounted) context.go('/photographers');
    } on FieldValidationException catch (error) {
      if (!mounted) return;
      _entityFormKey.currentState?.rejectValue(error.field);
      setState(() {
        _serverErrors
          ..clear()
          ..[error.field] = error.message;
        _revision++;
      });
      _formKey.currentState?.validate();
    } catch (error) {
      if (mounted) toast(context, 'Не удалось сохранить фотографа: $error');
    }
  }

  void _cancel() {
    context.go('/photographers');
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogNotifier>();
    return DirtyGuard(
      isDirty: () => _dirty,
      fallbackLocation: '/photographers',
      message: 'Есть несохранённые изменения. Выйти без сохранения?',
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go('/photographers')),
          title: Text(_photographer == null
              ? 'Новый фотограф'
              : 'Редактирование фотографа'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : widget.id != null && _photographer == null
                ? const Center(child: Text('Запись не найдена'))
                : EntityForm(
                    key: _entityFormKey,
                    formKey: _formKey,
                    fields: _fields(catalog),
                    rebuildToken: _revision,
                    saveLabel: _photographer == null
                        ? 'Создать фотографа'
                        : 'Сохранить изменения',
                    onSubmit: _save,
                    onCancel: _cancel,
                    onChanged: () => setState(() => _dirty = true),
                  ),
      ),
    );
  }
}
