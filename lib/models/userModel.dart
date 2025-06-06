class UserModel {
  final String id;
  final String email;
  
  UserModel({
    required this.id,
    required this.email,
  });
  
  // Create a model from Firebase User
  factory UserModel.fromFirebaseUser(user) {
    return UserModel(
      id: user.uid,
      email: user.email,
    );
  }
}