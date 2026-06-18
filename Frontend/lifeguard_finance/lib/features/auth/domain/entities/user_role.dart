enum UserRole {
  headOfFamily,
  familyMember,
}

extension UserRoleExtension on UserRole {
  String get key {
    switch (this) {
      case UserRole.headOfFamily:
        return 'head_of_family';
      case UserRole.familyMember:
        return 'family_member';
    }
  }

  static UserRole fromKey(String key) {
    if (key == 'head_of_family') return UserRole.headOfFamily;
    return UserRole.familyMember;
  }
}
