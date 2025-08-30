import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/supabase_service.dart';
import '../../services/sync_service.dart';
import 'users_event.dart';
import 'users_state.dart';

/// Bloc لإدارة المستخدمين
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final SupabaseService _supabaseService;
  final SyncService _syncService;

  // عدد العناصر في كل صفحة
  static const int _pageSize = 20;

  UsersBloc({
    required SupabaseService supabaseService,
    required SyncService syncService,
  })  : _supabaseService = supabaseService,
        _syncService = syncService,
        super(UsersInitial()) {
    on<UsersRequested>(_onUsersRequested);
    on<UserDetailsRequested>(_onUserDetailsRequested);
    on<UserUpdated>(_onUserUpdated);
    on<UserStatusUpdated>(_onUserStatusUpdated);
    on<UserAvatarUpdated>(_onUserAvatarUpdated);
  }

  /// معالجة حدث طلب قائمة المستخدمين
  Future<void> _onUsersRequested(
    UsersRequested event,
    Emitter<UsersState> emit,
  ) async {
    try {
      // إذا كان هناك طلب تحديث أو حالة أولية، نبدأ من الصفر
      if (event.refresh || state is UsersInitial) {
        emit(UsersLoading());
        
        final users = await _supabaseService.getUsers(
          role: event.role,
          search: event.search,
          limit: _pageSize,
        );
        
        emit(UsersLoaded(
          users: users,
          hasReachedMax: users.length < _pageSize,
          role: event.role,
          search: event.search,
        ));
      } else if (state is UsersLoaded) {
        // تحميل المزيد من المستخدمين (pagination)
        final currentState = state as UsersLoaded;
        
        // إذا تغيرت معايير البحث، نبدأ من الصفر
        if (currentState.role != event.role ||
            currentState.search != event.search) {
          emit(UsersLoading());
          
          final users = await _supabaseService.getUsers(
            role: event.role,
            search: event.search,
            limit: _pageSize,
          );
          
          emit(UsersLoaded(
            users: users,
            hasReachedMax: users.length < _pageSize,
            role: event.role,
            search: event.search,
          ));
        } else if (!currentState.hasReachedMax) {
          // تحميل الصفحة التالية
          final users = await _supabaseService.getUsers(
            role: event.role,
            search: event.search,
            limit: _pageSize,
            offset: currentState.users.length,
          );
          
          emit(users.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : currentState.copyWith(
                  users: [...currentState.users, ...users],
                  hasReachedMax: users.length < _pageSize,
                ));
        }
      }
    } catch (e) {
      emit(UserOperationFailure('فشل تحميل المستخدمين: ${e.toString()}'));
    }
  }

  /// معالجة حدث طلب تفاصيل مستخدم
  Future<void> _onUserDetailsRequested(
    UserDetailsRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());
    try {
      final user = await _supabaseService.getUserDetails(event.userId);
      
      if (user != null) {
        emit(UserDetailsLoaded(user));
      } else {
        emit(const UserOperationFailure('لم يتم العثور على المستخدم'));
      }
    } catch (e) {
      emit(UserOperationFailure('فشل تحميل تفاصيل المستخدم: ${e.toString()}'));
    }
  }

  /// معالجة حدث تحديث بيانات مستخدم
  Future<void> _onUserUpdated(
    UserUpdated event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());
    try {
      final success = await _supabaseService.updateUserProfile(
        event.userId,
        event.userData,
      );
      
      if (success) {
        // إضافة إجراء معلق للمزامنة في حالة عدم الاتصال
        await _syncService.addPendingAction({
          'type': 'update',
          'entity': 'user',
          'id': event.userId,
          'data': event.userData,
        });
        
        emit(const UserOperationSuccess(
          message: 'تم تحديث بيانات المستخدم بنجاح',
          operationType: 'update',
        ));
      } else {
        emit(const UserOperationFailure('فشل تحديث بيانات المستخدم'));
      }
    } catch (e) {
      emit(UserOperationFailure('فشل تحديث بيانات المستخدم: ${e.toString()}'));
    }
  }

  /// معالجة حدث تحديث حالة مستخدم (تفعيل/تعطيل)
  Future<void> _onUserStatusUpdated(
    UserStatusUpdated event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());
    try {
      final success = await _supabaseService.updateUserStatus(
        event.userId,
        event.isActive,
      );
      
      if (success) {
        // إضافة إجراء معلق للمزامنة في حالة عدم الاتصال
        await _syncService.addPendingAction({
          'type': 'update',
          'entity': 'user',
          'id': event.userId,
          'data': {'is_active': event.isActive},
        });
        
        final message = event.isActive
            ? 'تم تفعيل المستخدم بنجاح'
            : 'تم تعطيل المستخدم بنجاح';
        
        emit(UserOperationSuccess(
          message: message,
          operationType: 'status',
        ));
      } else {
        emit(const UserOperationFailure('فشل تحديث حالة المستخدم'));
      }
    } catch (e) {
      emit(UserOperationFailure('فشل تحديث حالة المستخدم: ${e.toString()}'));
    }
  }

  /// معالجة حدث تحديث صورة المستخدم
  Future<void> _onUserAvatarUpdated(
    UserAvatarUpdated event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());
    try {
      // رفع الصورة إلى تخزين Supabase
      final path = 'avatars/${event.userId}/${event.fileName}';
      final avatarUrl = await _supabaseService.uploadFile(
        'avatars',
        path,
        event.fileBytes,
        'image/jpeg',
      );
      
      if (avatarUrl != null) {
        // تحديث رابط الصورة في ملف المستخدم
        final success = await _supabaseService.updateUserProfile(
          event.userId,
          {'avatar': avatarUrl},
        );
        
        if (success) {
          // إضافة إجراء معلق للمزامنة في حالة عدم الاتصال
          await _syncService.addPendingAction({
            'type': 'update',
            'entity': 'user',
            'id': event.userId,
            'data': {'avatar': avatarUrl},
          });
          
          emit(const UserOperationSuccess(
            message: 'تم تحديث صورة المستخدم بنجاح',
            operationType: 'avatar',
          ));
        } else {
          emit(const UserOperationFailure('فشل تحديث صورة المستخدم'));
        }
      } else {
        emit(const UserOperationFailure('فشل رفع صورة المستخدم'));
      }
    } catch (e) {
      emit(UserOperationFailure('فشل تحديث صورة المستخدم: ${e.toString()}'));
    }
  }
}

