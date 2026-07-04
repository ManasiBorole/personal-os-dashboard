import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:personal_os_dashboard/features/meetings/data/services/meeting_pdf_exporter.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_form_state.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_params.dart';
import 'package:personal_os_dashboard/features/meetings/domain/usecases/meeting_usecases.dart';

final getMeetingsUseCaseProvider = Provider<GetMeetingsUseCase>((ref) {
  return GetMeetingsUseCase(ref.watch(meetingsRepositoryProvider));
});

final getMeetingByIdUseCaseProvider = Provider<GetMeetingByIdUseCase>((ref) {
  return GetMeetingByIdUseCase(ref.watch(meetingsRepositoryProvider));
});

final createMeetingUseCaseProvider = Provider<CreateMeetingUseCase>((ref) {
  return CreateMeetingUseCase(ref.watch(meetingsRepositoryProvider));
});

final updateMeetingUseCaseProvider = Provider<UpdateMeetingUseCase>((ref) {
  return UpdateMeetingUseCase(ref.watch(meetingsRepositoryProvider));
});

final deleteMeetingUseCaseProvider = Provider<DeleteMeetingUseCase>((ref) {
  return DeleteMeetingUseCase(ref.watch(meetingsRepositoryProvider));
});

final exportMeetingPdfUseCaseProvider = Provider<ExportMeetingPdfUseCase>((ref) {
  return ExportMeetingPdfUseCase(const MeetingPdfExporter());
});

final meetingsSearchQueryProvider = StateProvider<String>((ref) => '');

final meetingsFilterProvider =
    StateProvider<MeetingFilter>((ref) => MeetingFilter.empty);

final meetingsSortProvider = StateProvider<MeetingSortOption>(
  (ref) => MeetingSortOption.startTimeAsc,
);

final meetingsListProvider =
    AsyncNotifierProvider<MeetingsListController, List<Meeting>>(
  MeetingsListController.new,
);

class MeetingsListController extends AsyncNotifier<List<Meeting>> {
  @override
  Future<List<Meeting>> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<List<Meeting>> _load() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(getMeetingsUseCaseProvider).call(userId);
    return result.when(
      success: (meetings) => meetings,
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }
}

final filteredMeetingsProvider = Provider<List<Meeting>>((ref) {
  final meetings = ref.watch(meetingsListProvider).maybeWhen(
        data: (value) => value,
        orElse: () => const <Meeting>[],
      );
  final query = ref.watch(meetingsSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(meetingsFilterProvider);
  final sort = ref.watch(meetingsSortProvider);

  var result = meetings.where((meeting) {
    final matchesSearch = query.isEmpty ||
        meeting.title.toLowerCase().contains(query) ||
        meeting.agenda.toLowerCase().contains(query) ||
        meeting.location?.toLowerCase().contains(query) == true;

    final matchesTab = switch (filter.tab) {
      MeetingListTab.upcoming => meeting.isUpcoming,
      MeetingListTab.history =>
        meeting.isPast || meeting.status != MeetingStatus.scheduled,
    };

    final matchesStatus =
        filter.status == null || meeting.status == filter.status;

    return matchesSearch && matchesTab && matchesStatus;
  }).toList();

  result = List<Meeting>.from(result)
    ..sort((a, b) => _compareMeetings(a, b, sort, filter.tab));

  return result;
});

int _compareMeetings(
  Meeting a,
  Meeting b,
  MeetingSortOption sort,
  MeetingListTab tab,
) {
  return switch (sort) {
    MeetingSortOption.startTimeAsc => a.startTime.compareTo(b.startTime),
    MeetingSortOption.startTimeDesc => b.startTime.compareTo(a.startTime),
    MeetingSortOption.recentlyUpdated =>
      b.updatedAt.compareTo(a.updatedAt),
    MeetingSortOption.titleAsc =>
      a.title.toLowerCase().compareTo(b.title.toLowerCase()),
  };
}

final meetingFormControllerProvider =
    NotifierProvider<MeetingFormController, MeetingFormState>(
  MeetingFormController.new,
);

class MeetingFormController extends Notifier<MeetingFormState> {
  @override
  MeetingFormState build() => const MeetingFormIdle();

  Future<bool> createMeeting(CreateMeetingParams params) async {
    state = const MeetingFormLoading();
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(createMeetingUseCaseProvider).call(
          CreateMeetingRequest(userId: userId, meeting: params),
        );
    return result.when(
      success: (_) {
        state = const MeetingFormSuccess(message: 'Meeting created.');
        ref.invalidate(meetingsListProvider);
        ref.invalidate(dashboardSummaryProvider);
        return true;
      },
      onFailure: (f) {
        state = MeetingFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> updateMeeting(UpdateMeetingParams params) async {
    state = const MeetingFormLoading();
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(updateMeetingUseCaseProvider).call(
          UpdateMeetingRequest(userId: userId, meeting: params),
        );
    return result.when(
      success: (_) {
        state = const MeetingFormSuccess(message: 'Meeting updated.');
        ref.invalidate(meetingsListProvider);
        ref.invalidate(meetingDetailProvider(params.id));
        ref.invalidate(dashboardSummaryProvider);
        return true;
      },
      onFailure: (f) {
        state = MeetingFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> deleteMeeting(String id) async {
    state = const MeetingFormLoading();
    final result = await ref.read(deleteMeetingUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        state = const MeetingFormSuccess(message: 'Meeting deleted.');
        ref.invalidate(meetingsListProvider);
        ref.invalidate(dashboardSummaryProvider);
        return true;
      },
      onFailure: (f) {
        state = MeetingFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  void clearStatus() => state = const MeetingFormIdle();
}

final meetingDetailProvider =
    FutureProvider.family<Meeting, String>((ref, id) async {
  final result = await ref.read(getMeetingByIdUseCaseProvider).call(id);
  return result.when(
    success: (meeting) => meeting,
    onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
  );
});
