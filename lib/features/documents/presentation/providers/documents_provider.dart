import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document_form_state.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document_params.dart';
import 'package:personal_os_dashboard/features/documents/domain/usecases/document_usecases.dart';

final getFoldersUseCaseProvider = Provider<GetFoldersUseCase>((ref) {
  return GetFoldersUseCase(ref.watch(documentsRepositoryProvider));
});

final createFolderUseCaseProvider = Provider<CreateFolderUseCase>((ref) {
  return CreateFolderUseCase(ref.watch(documentsRepositoryProvider));
});

final deleteFolderUseCaseProvider = Provider<DeleteFolderUseCase>((ref) {
  return DeleteFolderUseCase(ref.watch(documentsRepositoryProvider));
});

final getDocumentsUseCaseProvider = Provider<GetDocumentsUseCase>((ref) {
  return GetDocumentsUseCase(ref.watch(documentsRepositoryProvider));
});

final getDocumentByIdUseCaseProvider = Provider<GetDocumentByIdUseCase>((ref) {
  return GetDocumentByIdUseCase(ref.watch(documentsRepositoryProvider));
});

final uploadDocumentUseCaseProvider = Provider<UploadDocumentUseCase>((ref) {
  return UploadDocumentUseCase(ref.watch(documentsRepositoryProvider));
});

final downloadDocumentUseCaseProvider = Provider<DownloadDocumentUseCase>((ref) {
  return DownloadDocumentUseCase(ref.watch(documentsRepositoryProvider));
});

final deleteDocumentUseCaseProvider = Provider<DeleteDocumentUseCase>((ref) {
  return DeleteDocumentUseCase(ref.watch(documentsRepositoryProvider));
});

final documentsSearchQueryProvider = StateProvider<String>((ref) => '');

final documentFilterProvider =
    StateProvider<DocumentFilterType>((ref) => DocumentFilterType.all);

final currentFolderIdProvider = StateProvider<String?>((ref) => null);

final folderBreadcrumbProvider = StateProvider<List<DocumentFolder>>((ref) => []);

typedef DocumentsBrowserState = ({
  List<DocumentFolder> folders,
  List<ManagedDocument> documents,
});

final documentsBrowserProvider =
    AsyncNotifierProvider<DocumentsBrowserController, DocumentsBrowserState>(
  DocumentsBrowserController.new,
);

class DocumentsBrowserController extends AsyncNotifier<DocumentsBrowserState> {
  @override
  Future<DocumentsBrowserState> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<DocumentsBrowserState> _load() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final folderId = ref.read(currentFolderIdProvider);

    final foldersResult = await ref.read(getFoldersUseCaseProvider).call(
          GetFoldersRequest(userId: userId, parentId: folderId),
        );
    final documentsResult = await ref.read(getDocumentsUseCaseProvider).call(
          GetDocumentsRequest(userId: userId, folderId: folderId),
        );

    return foldersResult.when(
      success: (folders) => documentsResult.when(
        success: (documents) => (folders: folders, documents: documents),
        onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
      ),
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }

  Future<void> navigateToFolder(DocumentFolder? folder) async {
    if (folder == null) {
      ref.read(currentFolderIdProvider.notifier).state = null;
      ref.read(folderBreadcrumbProvider.notifier).state = [];
    } else {
      ref.read(currentFolderIdProvider.notifier).state = folder.id;
      final crumbs = ref.read(folderBreadcrumbProvider);
      ref.read(folderBreadcrumbProvider.notifier).state = [...crumbs, folder];
    }
    await refresh();
  }

  Future<void> navigateToBreadcrumb(int index) async {
    final crumbs = ref.read(folderBreadcrumbProvider);
    if (index < 0) {
      ref.read(currentFolderIdProvider.notifier).state = null;
      ref.read(folderBreadcrumbProvider.notifier).state = [];
    } else {
      final target = crumbs[index];
      ref.read(currentFolderIdProvider.notifier).state = target.id;
      ref.read(folderBreadcrumbProvider.notifier).state =
          crumbs.sublist(0, index + 1);
    }
    await refresh();
  }
}

final filteredDocumentsBrowserProvider = Provider<DocumentsBrowserState>((ref) {
  final browser = ref.watch(documentsBrowserProvider).maybeWhen(
        data: (value) => value,
        orElse: () => (folders: <DocumentFolder>[], documents: <ManagedDocument>[]),
      );
  final query = ref.watch(documentsSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(documentFilterProvider);

  var folders = browser.folders;
  var documents = browser.documents;

  if (filter.fileType != null) {
    documents = documents
        .where((doc) => doc.fileType == filter.fileType)
        .toList();
  }

  if (query.isNotEmpty) {
    folders = folders
        .where((f) => f.name.toLowerCase().contains(query))
        .toList();
    documents = documents.where((doc) {
      return doc.name.toLowerCase().contains(query) ||
          doc.fileName.toLowerCase().contains(query);
    }).toList();
  }

  return (folders: folders, documents: documents);
});

final documentFormControllerProvider =
    NotifierProvider<DocumentFormController, DocumentFormState>(
  DocumentFormController.new,
);

class DocumentFormController extends Notifier<DocumentFormState> {
  @override
  DocumentFormState build() => const DocumentFormIdle();

  Future<bool> createFolder(CreateFolderParams params) async {
    state = const DocumentFormLoading();
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(createFolderUseCaseProvider).call(
          CreateFolderRequest(userId: userId, folder: params),
        );
    return result.when(
      success: (_) {
        state = const DocumentFormSuccess(message: 'Folder created.');
        ref.invalidate(documentsBrowserProvider);
        return true;
      },
      onFailure: (f) {
        state = DocumentFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> uploadDocument(UploadDocumentParams params) async {
    state = const DocumentFormLoading();
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(uploadDocumentUseCaseProvider).call(
          UploadDocumentRequest(userId: userId, document: params),
        );
    return result.when(
      success: (_) {
        state = const DocumentFormSuccess(message: 'Document uploaded.');
        ref.invalidate(documentsBrowserProvider);
        return true;
      },
      onFailure: (f) {
        state = DocumentFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> deleteFolder(String id) async {
    state = const DocumentFormLoading();
    final result = await ref.read(deleteFolderUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        state = const DocumentFormSuccess(message: 'Folder deleted.');
        ref.invalidate(documentsBrowserProvider);
        return true;
      },
      onFailure: (f) {
        state = DocumentFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> deleteDocument(ManagedDocument document) async {
    state = const DocumentFormLoading();
    final result = await ref.read(deleteDocumentUseCaseProvider).call(document);
    return result.when(
      success: (_) {
        state = const DocumentFormSuccess(message: 'Document deleted.');
        ref.invalidate(documentsBrowserProvider);
        return true;
      },
      onFailure: (f) {
        state = DocumentFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<Uint8List?> downloadDocument(ManagedDocument document) async {
    final result =
        await ref.read(downloadDocumentUseCaseProvider).call(document);
    return result.when(
      success: (bytes) => bytes,
      onFailure: (f) {
        state = DocumentFormError(sl<ErrorHandler>().getUserMessage(f));
        return null;
      },
    );
  }

  void clearStatus() => state = const DocumentFormIdle();
}

final documentDetailProvider =
    FutureProvider.family<ManagedDocument, String>((ref, id) async {
  final result = await ref.read(getDocumentByIdUseCaseProvider).call(id);
  return result.when(
    success: (document) => document,
    onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
  );
});

final documentPreviewBytesProvider =
    FutureProvider.family<Uint8List, String>((ref, id) async {
  final document = await ref.watch(documentDetailProvider(id).future);
  final result =
      await ref.read(downloadDocumentUseCaseProvider).call(document);
  return result.when(
    success: (bytes) => bytes,
    onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
  );
});
