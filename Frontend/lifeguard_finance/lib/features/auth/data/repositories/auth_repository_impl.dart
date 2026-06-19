import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/family_account.dart';
import '../../domain/entities/family_invitation.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

import '../../../../core/network/api_client.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.apiClient,
  });

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();

  // Helper methods for code generation and normalization
  String generateFamilyCode() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return 'LGF-${random.toString().padLeft(6, '0')}';
  }

  String generateInviteCode() {
    final random = DateTime.now().microsecondsSinceEpoch % 1000000;
    return 'INV-${random.toString().padLeft(6, '0')}';
  }

  String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  String normalizeCode(String code) {
    return code.trim().toUpperCase();
  }

  @override
  Future<void> registerHeadOfFamily({
    required String fullName,
    required String email,
    required String password,
    required String familyName,
    String phoneNumber = '',
  }) async {
    final normalizedEmail = normalizeEmail(email);
    // Check if user already exists
    final existingUser = await localDataSource.getUser(normalizedEmail);
    if (existingUser != null) {
      throw Exception('Email sudah terdaftar');
    }

    final userId = _generateId();
    final familyId = _generateId();
    final familyCode = generateFamilyCode();

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
      email: normalizedEmail,
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

    // 1. Firebase Auth Registration
    try {
      await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      
      // 2. Sync to Backend
      await apiClient.dio.post('/auth/sync-user', data: {
        'role': 'HEAD_OF_FAMILY',
      });
    } catch (e) {
      debugPrint('Firebase/Backend Auth Error: $e');
      throw Exception('Gagal registrasi dengan server: $e');
    }

    await localDataSource.saveFamilyAccount(familyAccount);
    await localDataSource.saveUser(user);
    await localDataSource.saveAuthSession(session);
  }

  @override
  Future<AppUser> login(String email, String password) async {
    final normalizedEmail = normalizeEmail(email);
    
    // 1. Firebase Auth Login FIRST
    try {
      await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } catch (e) {
      debugPrint('Firebase Auth Login Error: $e');
      throw Exception('Gagal login ke server. Pastikan email dan password benar.');
    }

    // 2. After Firebase succeeds, get user from local cache
    var user = await localDataSource.getUser(normalizedEmail);
    
    if (user == null) {
      // 3. If missing in local cache (e.g. cleared browser data), fetch from backend
      try {
        final response = await apiClient.dio.get('/users/me');
        final userData = response.data['data'];
        
        final roles = userData['roles'] as List<dynamic>? ?? [];
        final roleStr = roles.isNotEmpty ? roles[0].toString() : 'FAMILY_MEMBER';
        final userRole = roleStr == 'HEAD_OF_FAMILY' ? UserRole.headOfFamily : UserRole.familyMember;
        
        user = AppUser(
          userId: userData['id'],
          familyId: userData['familyId'] ?? _generateId(),
          fullName: userData['displayName'] ?? normalizedEmail.split('@')[0],
          email: normalizedEmail,
          passwordHash: password, // For local cache prototype
          role: userRole,
          relation: userRole == UserRole.headOfFamily ? 'head_of_family' : 'member',
          isActive: userData['isActive'] ?? true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await localDataSource.saveUser(user);
      } catch (e) {
        debugPrint('Backend fetch users/me error: $e');
        throw Exception('Gagal sinkronisasi data dengan server. $e');
      }
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
    await fb_auth.FirebaseAuth.instance.signOut();
    await localDataSource.clearAuthSession();
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    return await localDataSource.getCurrentSession();
  }

  @override
  AuthSession? getCachedSession() {
    final sessionMap = localDataSource.hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.authSession);
    if (sessionMap != null) {
      return AuthSession.fromJson(sessionMap);
    }
    return null;
  }

  @override
  Future<bool> checkIsFamilyProfileCompleted() async {
    final profileMap = localDataSource.hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.familyProfile);
    return profileMap != null && profileMap.isNotEmpty;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final session = await localDataSource.getCurrentSession();
    if (session == null || !session.isLoggedIn) return null;
    
    final members = await localDataSource.getFamilyMembers(session.currentFamilyId);
    try {
      return members.firstWhere((u) => u.userId == session.currentUserId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> checkEmailAlreadyRegistered(String email) async {
    final normalizedEmail = normalizeEmail(email);
    final user = await localDataSource.getUser(normalizedEmail);
    return user != null;
  }

  @override
  Future<String> inviteFamilyMember({
    required String fullName,
    required String email,
    required String relation,
    required bool isActive,
  }) async {
    final session = await localDataSource.getCurrentSession();
    if (session == null || !session.isLoggedIn) {
      throw Exception('Sesi tidak valid');
    }
    if (session.currentUserRole != UserRole.headOfFamily) {
      throw Exception('Hanya Kepala Keluarga yang bisa mengundang anggota');
    }

    final normalizedEmail = normalizeEmail(email);

    final existingUser = await localDataSource.getUser(normalizedEmail);
    if (existingUser != null) {
      throw Exception('Email sudah terdaftar sebagai pengguna');
    }

    final invitations = await localDataSource.getFamilyInvitations(session.currentFamilyId);
    if (invitations.any((i) => normalizeEmail(i.invitedEmail) == normalizedEmail && i.status == 'pending')) {
      throw Exception('Email ini sudah diundang dan masih pending');
    }

    final inviteCode = generateInviteCode();
    final invitation = FamilyInvitation(
      invitationId: _generateId(),
      familyId: session.currentFamilyId,
      invitedEmail: normalizedEmail,
      invitedName: fullName,
      relation: relation,
      inviteCode: inviteCode,
      roleToAssign: UserRole.familyMember,
      status: 'pending',
      createdByUserId: session.currentUserId,
      createdAt: DateTime.now(),
    );

    await localDataSource.saveFamilyInvitation(invitation);
    return inviteCode;
  }

  @override
  Future<void> activateFamilyMemberInvitation({
    required String email,
    required String familyCode,
    required String inviteCode,
    required String newPassword,
  }) async {
    final normalizedEmail = normalizeEmail(email);
    final normalizedFamilyCode = normalizeCode(familyCode);
    final normalizedInviteCode = normalizeCode(inviteCode);

    debugPrint('ACTIVATE email: $normalizedEmail');
    debugPrint('ACTIVATE familyCode: $normalizedFamilyCode');
    debugPrint('ACTIVATE inviteCode: $normalizedInviteCode');

    final familiesRaw = localDataSource.hiveService.getData<List<dynamic>>(LocalKeys.families) ?? [];
    debugPrint('Families count: ${familiesRaw.length}');

    final invitationsRaw = localDataSource.hiveService.getData<List<dynamic>>(LocalKeys.familyInvitations) ?? [];
    debugPrint('Invitations count: ${invitationsRaw.length}');

    final family = await localDataSource.getFamilyAccountByCode(normalizedFamilyCode);
    debugPrint('Matched family: ${family?.familyId}');

    final invitation = await localDataSource.getFamilyInvitationByCode(normalizedFamilyCode, normalizedInviteCode);
    debugPrint('Matched invitation: ${invitation?.invitationId}');

    if (family == null) {
      debugPrint('Alasan gagal: Kode keluarga tidak ditemukan.');
      throw Exception('Kode keluarga tidak ditemukan.');
    }

    final isMatched = invitation != null &&
        invitation.familyId == family.familyId &&
        normalizeEmail(invitation.invitedEmail) == normalizedEmail &&
        normalizeCode(invitation.inviteCode) == normalizedInviteCode &&
        invitation.status == 'pending';

    if (!isMatched) {
      debugPrint('Alasan gagal: Email ini belum diundang oleh Kepala Keluarga atau kode undangan tidak sesuai.');
      throw Exception('Email ini belum diundang oleh Kepala Keluarga atau kode undangan tidak sesuai.');
    }

    final existingUser = await localDataSource.getUser(normalizedEmail);
    if (existingUser != null) {
      debugPrint('Alasan gagal: Email ini sudah memiliki akun.');
      throw Exception('Email ini sudah memiliki akun.');
    }

    // Buat User Baru
    final newUser = AppUser(
      userId: _generateId(),
      familyId: invitation.familyId,
      fullName: invitation.invitedName,
      email: normalizedEmail,
      passwordHash: newPassword, // In prototype, storing plain password
      role: UserRole.familyMember,
      relation: invitation.relation,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await localDataSource.saveUser(newUser);

    // Update Invitation Status
    final acceptedInvitation = FamilyInvitation(
      invitationId: invitation.invitationId,
      familyId: invitation.familyId,
      invitedEmail: invitation.invitedEmail,
      invitedName: invitation.invitedName,
      relation: invitation.relation,
      inviteCode: invitation.inviteCode,
      roleToAssign: invitation.roleToAssign,
      status: 'accepted',
      createdByUserId: invitation.createdByUserId,
      createdAt: invitation.createdAt,
      acceptedAt: DateTime.now(),
    );
    await localDataSource.saveFamilyInvitation(acceptedInvitation);

    // Auto login
    final session = AuthSession(
      currentUserId: newUser.userId,
      currentFamilyId: newUser.familyId,
      currentUserRole: UserRole.familyMember,
      isLoggedIn: true,
      loginAt: DateTime.now(),
    );

    // 1. Firebase Auth Registration
    try {
      await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: newPassword,
      );
      
      // 2. Sync to Backend
      await apiClient.dio.post('/auth/sync-user', data: {
        'role': 'FAMILY_MEMBER',
        'inviteCode': normalizedInviteCode,
      });
    } catch (e) {
      debugPrint('Firebase/Backend Auth Error: $e');
      throw Exception('Gagal aktivasi anggota keluarga di server: $e');
    }

    await localDataSource.saveAuthSession(session);
  }

  @override
  Future<List<AppUser>> getFamilyMembers() async {
    final session = await localDataSource.getCurrentSession();
    if (session == null || !session.isLoggedIn) {
      return [];
    }
    return await localDataSource.getFamilyMembers(session.currentFamilyId);
  }

  @override
  Future<List<FamilyInvitation>> getFamilyInvitations() async {
    final session = await localDataSource.getCurrentSession();
    if (session == null || !session.isLoggedIn) {
      return [];
    }
    return await localDataSource.getFamilyInvitations(session.currentFamilyId);
  }

  @override
  Future<FamilyAccount?> getFamilyAccount() async {
    final session = await localDataSource.getCurrentSession();
    if (session == null || !session.isLoggedIn) {
      return null;
    }
    return await localDataSource.getFamilyAccount(session.currentFamilyId);
  }
}
