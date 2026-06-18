import 'dart:math';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/family_account.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();

  @override
  Future<void> registerHeadOfFamily({
    required String fullName,
    required String email,
    required String password,
    required String familyName,
    String phoneNumber = '',
  }) async {
    // Check if user already exists
    final existingUser = await localDataSource.getUser(email);
    if (existingUser != null) {
      throw Exception('Email sudah terdaftar');
    }

    final userId = _generateId();
    final familyId = _generateId();
    final familyCode = 'LGF-${Random().nextInt(900000) + 100000}';

    final familyAccount = FamilyAccount(
      familyId: familyId,
      familyName: familyName,
      familyCode: familyCode,
      headUserId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final user = AppUser(
      userId: userId,
      familyId: familyId,
      fullName: fullName,
      email: email,
      passwordHash: password, // In prototype, storing plain password or simple hash
      role: UserRole.headOfFamily,
      relation: 'head_of_family',
      phoneNumber: phoneNumber,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final session = AuthSession(
      currentUserId: userId,
      currentFamilyId: familyId,
      currentUserRole: UserRole.headOfFamily,
      isLoggedIn: true,
      loginAt: DateTime.now(),
    );

    await localDataSource.saveFamilyAccount(familyAccount);
    await localDataSource.saveUser(user);
    await localDataSource.saveAuthSession(session);
  }

  @override
  Future<AppUser> login(String email, String password) async {
    final user = await localDataSource.getUser(email);
    if (user == null) {
      throw Exception('Email tidak ditemukan');
    }
    
    // Prototype: Check password match
    if (user.passwordHash != password) {
      throw Exception('Kata sandi salah');
    }

    if (!user.isActive) {
      throw Exception('Akun tidak aktif');
    }

    final session = AuthSession(
      currentUserId: user.userId,
      currentFamilyId: user.familyId,
      currentUserRole: user.role,
      isLoggedIn: true,
      loginAt: DateTime.now(),
    );

    await localDataSource.saveAuthSession(session);
    return user;
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAuthSession();
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    return await localDataSource.getCurrentSession();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final session = await localDataSource.getCurrentSession();
    if (session == null || !session.isLoggedIn) return null;
    
    // In our prototype, user ID and email are distinct, but our getUser only checks email.
    // Wait, let's fix getUser to check userId or email, or we just get all users and find by ID.
    // For now, we will add logic in getFamilyMembers to find by ID
    // Let's get all users and find by userId:
    final members = await localDataSource.getFamilyMembers(session.currentFamilyId);
    try {
      return members.firstWhere((u) => u.userId == session.currentUserId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addFamilyMember({
    required String fullName,
    required String email,
    required String password,
    required String relation,
    required bool isActive,
  }) async {
    final session = await localDataSource.getCurrentSession();
    if (session == null || !session.isLoggedIn) {
      throw Exception('Sesi tidak valid');
    }
    if (session.currentUserRole != UserRole.headOfFamily) {
      throw Exception('Hanya Kepala Keluarga yang bisa menambahkan anggota');
    }

    final existingUser = await localDataSource.getUser(email);
    if (existingUser != null) {
      throw Exception('Email/Username sudah digunakan');
    }

    final newUser = AppUser(
      userId: _generateId(),
      familyId: session.currentFamilyId,
      fullName: fullName,
      email: email,
      passwordHash: password,
      role: UserRole.familyMember,
      relation: relation,
      isActive: isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await localDataSource.saveUser(newUser);
  }

  @override
  Future<List<AppUser>> getFamilyMembers() async {
    final session = await localDataSource.getCurrentSession();
    if (session == null || !session.isLoggedIn) {
      return [];
    }
    return await localDataSource.getFamilyMembers(session.currentFamilyId);
  }
}
