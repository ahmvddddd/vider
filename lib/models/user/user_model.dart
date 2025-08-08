class User {
  final String? firstname;
  final String? lastname;
  final String? username;
  final String? email;
  final String? password;

  User({
    this.firstname,
    this.lastname,
     this.username,
     this.email,
     this.password
  });
}

class LoginState {
  final bool isLoading;
  final String? error;
  final User? user;

  LoginState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    User? user,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

class SignupState {
  final bool isLoading;
  final String? error;
  final User? user;

  SignupState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  SignupState copyWith({
    bool? isLoading,
    String? error,
    User? user,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}
