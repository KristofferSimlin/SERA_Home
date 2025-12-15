import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sera/data/openai_client.dart';
import '../chat/chat_controller.dart';
import '../../data/web_search_client.dart';

const _sentinel = Object();
const String serviceTypeCustomKey = '__custom';

class ServiceState {
  final String brand;
  final String model;
  final String? year;
  final String serviceType;
  final String? customServiceType;
  final String? output;
  final bool isGenerating;
  final String? error;

  const ServiceState({
    this.brand = '',
    this.model = '',
    this.year,
    this.serviceType = '50 h',
    this.customServiceType,
    this.output,
    this.isGenerating = false,
    this.error,
  });

  ServiceState copyWith({
    String? brand,
    String? model,
    Object? year = _sentinel,
    String? serviceType,
    Object? customServiceType = _sentinel,
    Object? output = _sentinel,
    bool? isGenerating,
    Object? error = _sentinel,
  }) {
    return ServiceState(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: identical(year, _sentinel) ? this.year : year as String?,
      serviceType: serviceType ?? this.serviceType,
      customServiceType: identical(customServiceType, _sentinel)
          ? this.customServiceType
          : customServiceType as String?,
      output: identical(output, _sentinel) ? this.output : output as String?,
      isGenerating: isGenerating ?? this.isGenerating,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

class ServiceController extends StateNotifier<ServiceState> {
  ServiceController({
    required this.client,
    required this.settings,
  }) : super(const ServiceState());

  final OpenAIClient client;
  final SettingsState settings;
  final WebSearchClient _webSearch = WebSearchClient();

  void updateBrand(String value) {
    state = state.copyWith(brand: value, error: null);
  }

  void updateModel(String value) {
    state = state.copyWith(model: value, error: null);
  }

  void updateYear(String? value) {
    state = state.copyWith(year: value, error: null);
  }

  void updateServiceType(String value) {
    state = state.copyWith(serviceType: value, error: null);
  }

  void updateCustomServiceType(String value) {
    state = state.copyWith(customServiceType: value, error: null);
  }

  String? _resolvedServiceType() {
    if (state.serviceType == serviceTypeCustomKey) {
      final custom = state.customServiceType?.trim();
      if (custom == null || custom.isEmpty) return null;
      return custom;
    }
    final base = state.serviceType.trim();
    return base.isEmpty ? null : base;
  }

  bool get hasRequiredFields {
    return state.brand.trim().isNotEmpty &&
        state.model.trim().isNotEmpty &&
        _resolvedServiceType() != null &&
        !state.isGenerating;
  }

  Future<String?> _fetchWebNotes() async {
    final parts = [
      state.brand.trim(),
      state.model.trim(),
      state.year?.trim() ?? '',
      _resolvedServiceType() ?? '',
    ].where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    final query = parts.join(' ');
    try {
      return await _webSearch.searchSummary(
        query,
        brand: state.brand,
        model: state.model,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> generate() async {
    final resolvedType = _resolvedServiceType();
    if (!hasRequiredFields || resolvedType == null) return;

    state = state.copyWith(isGenerating: true, error: null);
    try {
      String? webNotes;
      if (settings.webLookupEnabled) {
        webNotes = await _fetchWebNotes();
        debugPrint('service webNotes: ${webNotes ?? '(none)'}');
      }
      final output = await client.generateServicePlan(
        brand: state.brand.trim(),
        model: state.model.trim(),
        year: state.year?.trim().isEmpty == true ? null : state.year?.trim(),
        serviceType: resolvedType,
        preferSwedish: settings.localeCode.startsWith('sv'),
        webNotes: webNotes,
      );
      state = state.copyWith(isGenerating: false, output: output);
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: e.toString());
    }
  }

  void clear() {
    state = const ServiceState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final serviceControllerProvider =
    StateNotifierProvider<ServiceController, ServiceState>((ref) {
  final settings = ref.watch(settingsProvider);
  final client = OpenAIClient.fromSettings(settings);
  return ServiceController(client: client, settings: settings);
});
