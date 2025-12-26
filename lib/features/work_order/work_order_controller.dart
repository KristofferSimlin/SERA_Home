import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sera/data/openai_client.dart';
import '../chat/chat_controller.dart';

const _sentinel = Object();

class WorkOrderState {
  final String description;
  final String? result;
  final bool isLoading;
  final String? error;

  const WorkOrderState({
    this.description = '',
    this.result,
    this.isLoading = false,
    this.error,
  });

  WorkOrderState copyWith({
    String? description,
    Object? result = _sentinel,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return WorkOrderState(
      description: description ?? this.description,
      result: identical(result, _sentinel) ? this.result : result as String?,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

class WorkOrderController extends StateNotifier<WorkOrderState> {
  WorkOrderController({
    required this.client,
    required this.settings,
  }) : super(const WorkOrderState());

  final OpenAIClient client;
  final SettingsState settings;

  void updateDescription(String value) {
    state = state.copyWith(description: value, error: null);
  }

  void setResult(String value) {
    state = state.copyWith(result: value, error: null);
  }

  Future<void> generate() async {
    final input = state.description.trim();
    if (input.isEmpty || state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await client.generateWorkOrder(
        input,
        preferSwedish: settings.localeCode.startsWith('sv'),
      );
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearResult() {
    state = state.copyWith(result: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final workOrderControllerProvider =
    StateNotifierProvider<WorkOrderController, WorkOrderState>((ref) {
  final settings = ref.watch(settingsProvider);
  final client = OpenAIClient.fromSettings(settings);
  return WorkOrderController(client: client, settings: settings);
});
