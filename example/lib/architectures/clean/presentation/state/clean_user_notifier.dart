import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/fetch_user_profile_usecase.dart';

/// Clean Architecture - Presentation State Handler
enum CleanUserState { initial, loading, loaded, error }

class CleanUserNotifier extends ChangeNotifier {
  final FetchUserProfileUseCase fetchUserProfileUseCase;

  CleanUserNotifier({required this.fetchUserProfileUseCase});

  CleanUserState _state = CleanUserState.initial;
  CleanUserState get state => _state;

  UserEntity? _user;
  UserEntity? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserProfile(String userId) async {
    _state = CleanUserState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await fetchUserProfileUseCase(userId);
      _state = CleanUserState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CleanUserState.error;
    }
    notifyListeners();
  }
}
