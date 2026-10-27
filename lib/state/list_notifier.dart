import 'package:flutter/foundation.dart';
import '../models/page_result.dart';

enum LoadStatus { idle, loading, success, error }

abstract class ListNotifier<T> extends ChangeNotifier {
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  PageResult<T> _result = PageResult.empty();
  final Set<int> _selected = {};
  LoadStatus get status => _status;
  String? get error => _error;
  PageResult<T> get result => _result;
  Set<int> get selected => Set.unmodifiable(_selected);
  List<int> get selectedIds => _selected.toList();
  bool get hasSelection => _selected.isNotEmpty;
  Future<void> applyQuery(Object query) async {
    clearSelection();
    await load();
  }

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _result = await fetch();
      _status = LoadStatus.success;
    } catch (error) {
      _error = error.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> Function()? onMutation;
  Future<void> mutate(Future<void> Function() action) async {
    try {
      await action();
      await onMutation?.call();
    } catch (error) {
      _error = error.toString();
      _status = LoadStatus.error;
      notifyListeners();
    }
  }

  Future<PageResult<T>> fetch();
  void toggle(int id) {
    if (!_selected.remove(id)) _selected.add(id);
    notifyListeners();
  }

  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }

  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<void> deleteSelected();
  Future<void> eraseSelected();
}
