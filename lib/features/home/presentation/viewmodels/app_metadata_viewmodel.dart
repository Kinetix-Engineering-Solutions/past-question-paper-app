import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/core/shared/models/app_metadata.dart';
import 'package:past_question_paper_v1/core/shared/services/app_metadata_cache.dart';
import 'package:past_question_paper_v1/core/shared/services/app_metadata_service.dart';

final appMetadataViewModelProvider =
    StateNotifierProvider<AppMetadataViewModel, AppMetadataState>((ref) {
      return AppMetadataViewModel(
        service: AppMetadataService(),
        cache: const AppMetadataCache(),
      );
    });

class AppMetadataState {
  final AppMetadata? metadata;
  final bool isLoading;
  final String? errorMessage;

  const AppMetadataState({
    required this.metadata,
    required this.isLoading,
    required this.errorMessage,
  });

  factory AppMetadataState.initial() => const AppMetadataState(
    metadata: null,
    isLoading: true,
    errorMessage: null,
  );

  AppMetadataState copyWith({
    AppMetadata? metadata,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppMetadataState(
      metadata: metadata ?? this.metadata,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AppMetadataViewModel extends StateNotifier<AppMetadataState> {
  final AppMetadataService _service;
  final AppMetadataCache _cache;

  AppMetadataViewModel({
    required AppMetadataService service,
    required AppMetadataCache cache,
  }) : _service = service,
       _cache = cache,
       super(AppMetadataState.initial()) {
    unawaited(_load());
  }

  Future<void> refresh() async {
    try {
      await _refreshFromRemote(forceUpdate: true);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not refresh subjects. Please try again.',
      );
    }
  }

  Future<void> _load() async {
    // Zero-wait: show cached content immediately if present.
    final cachedRaw = await _cache.readRawJson();
    final cached = _tryParseMetadata(cachedRaw);

    if (cached != null) {
      state = state.copyWith(
        metadata: cached,
        isLoading: false,
        errorMessage: null,
      );
      // Refresh silently in background.
      unawaited(_safeBackgroundRefresh(forceUpdate: true));
      return;
    }

    // First launch (no cache): show loading indicator while fetching.
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _refreshFromRemote(forceUpdate: true);
    } catch (_) {
      // If we still have no cache, show the required first-launch offline message.
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Please connect to the internet to download your subjects for the first time.',
      );
    }
  }

  Future<void> _safeBackgroundRefresh({required bool forceUpdate}) async {
    try {
      await _refreshFromRemote(forceUpdate: forceUpdate);
    } catch (_) {
      // Keep cached content; background refresh failures are non-fatal.
    }
  }

  Future<void> _refreshFromRemote({required bool forceUpdate}) async {
    final raw = await _service.fetchRawJson(bustCache: forceUpdate);
    final remote = _tryParseMetadata(raw);
    if (remote == null) {
      throw Exception('Invalid metadata JSON.');
    }

    final local = state.metadata;
    final shouldReplace =
        forceUpdate ||
        local == null ||
        remote.lastUpdated.isAfter(local.lastUpdated);

    if (!shouldReplace) {
      // Remote not newer per last_updated, but content might still have changed.
      final cachedRaw = await _cache.readRawJson();
      if (cachedRaw == null || cachedRaw.trim() == raw.trim()) {
        return;
      }
    }

    await _cache.writeRawJson(raw);
    state = state.copyWith(
      metadata: remote,
      isLoading: false,
      errorMessage: null,
    );
  }

  AppMetadata? _tryParseMetadata(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = json.decode(raw);
      if (decoded is! Map) return null;
      return AppMetadata.fromJson(decoded.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }
}
