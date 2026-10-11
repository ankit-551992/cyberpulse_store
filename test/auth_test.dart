import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:cyberpulse_store/services/auth_service.dart';
import 'package:cyberpulse_store/providers/store_provider.dart';
import 'package:cyberpulse_store/widgets/auth_modal.dart';
import 'package:cyberpulse_store/widgets/user_profile_modal.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService Unit Tests', () {
    test('Demo Customer authentication succeeds', () async {
      final authService = AuthService();
      final result = await authService.signIn(
        email: 'aarav.sharma@cyberpulse.in',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.user, isNotNull);
      expect(result.user!.name, equals('Aarav Sharma'));
      expect(result.user!.role, equals(UserRole.customer));
      expect(result.user!.isAdmin, isFalse);
    });

    test('Demo Admin authentication succeeds', () async {
      final authService = AuthService();
      final result = await authService.signIn(
        email: 'admin@cyberpulse.in',
        password: 'admin2077',
      );

      expect(result.isSuccess, isTrue);
      expect(result.user, isNotNull);
      expect(result.user!.name, equals('Alex Vance'));
      expect(result.user!.role, equals(UserRole.admin));
      expect(result.user!.isAdmin, isTrue);
    });

    test('Invalid credentials fail with descriptive error message', () async {
      final authService = AuthService();
      final result = await authService.signIn(
        email: 'admin@cyberpulse.in',
        password: 'wrong_password_999',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, isNotNull);
      expect(result.user, isNull);
    });

    test('User registration persists new user account', () async {
      final authService = AuthService();
      final result = await authService.signUp(
        name: 'Rohan Mehra',
        email: 'rohan.mehra@example.in',
        password: 'securePassword456',
        phone: '+91 99887 76655',
        role: UserRole.customer,
        city: 'Mumbai',
        pincode: '400001',
      );

      expect(result.isSuccess, isTrue);
      expect(result.user, isNotNull);
      expect(result.user!.name, equals('Rohan Mehra'));
      expect(result.user!.email, equals('rohan.mehra@example.in'));

      // Now verify can sign in with newly registered credentials
      final loginResult = await authService.signIn(
        email: 'rohan.mehra@example.in',
        password: 'securePassword456',
      );
      expect(loginResult.isSuccess, isTrue);
      expect(loginResult.user!.name, equals('Rohan Mehra'));
    });

    test('Registration rejects duplicate email addresses', () async {
      final authService = AuthService();
      final result = await authService.signUp(
        name: 'Duplicate Alex',
        email: 'admin@cyberpulse.in',
        password: 'password123',
        phone: '+91 98888 77777',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage?.contains('already exists'), isTrue);
    });
  });

  group('StoreProvider Authentication & Access Gate Tests', () {
    test('StoreProvider switches between Customer and Admin personas', () async {
      final store = StoreProvider();
      await store.loginAsDemoCustomer();
      expect(store.currentUser?.name, equals('Aarav Sharma'));
      expect(store.isCurrentUserAdmin, isFalse);

      // Customer should not be able to set admin mode via trySetAdminMode
      final canAccessAdmin = store.trySetAdminMode(true);
      expect(canAccessAdmin, isFalse);
      expect(store.isAdminMode, isFalse);

      // Now switch to Admin
      await store.loginAsDemoAdmin();
      expect(store.currentUser?.name, equals('Alex Vance'));
      expect(store.isCurrentUserAdmin, isTrue);

      final adminAccessGranted = store.trySetAdminMode(true);
      expect(adminAccessGranted, isTrue);
      expect(store.isAdminMode, isTrue);
    });

    test('Sign out clears session and exits admin mode if active', () async {
      final store = StoreProvider();
      await store.loginAsDemoAdmin();
      store.setAdminMode(true);
      expect(store.isAdminMode, isTrue);

      await store.signOut();
      expect(store.currentUser, isNull);
      expect(store.isAuthenticated, isFalse);
      expect(store.isAdminMode, isFalse);
    });

    test('myOrders returns orders matching active user', () async {
      final store = StoreProvider();
      await store.loginAsDemoCustomer();
      final orders = store.myOrders;
      expect(orders, isNotEmpty);
    });
  });

  group('AuthModal & UserProfileModal Widget Tests', () {
    testWidgets('AuthModal renders Sign In and Create Identity tabs with demo buttons', (tester) async {
      final store = StoreProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<StoreProvider>.value(
              value: store,
              child: const AuthModal(),
            ),
          ),
        ),
      );

      expect(find.text('⚡ SIGN IN'), findsOneWidget);
      expect(find.text('✨ CREATE IDENTITY'), findsOneWidget);
      expect(find.text('Demo Customer'), findsOneWidget);
      expect(find.text('Demo Admin'), findsOneWidget);

      // Switch to Create Identity tab
      await tester.tap(find.text('✨ CREATE IDENTITY'));
      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('CREATE CYBER IDENTITY'), findsOneWidget);
    });

    testWidgets('UserProfileModal renders active user details and actions', (tester) async {
      final store = StoreProvider();
      await store.loginAsDemoCustomer();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<StoreProvider>.value(
              value: store,
              child: const UserProfileModal(),
            ),
          ),
        ),
      );

      expect(find.text('Aarav Sharma'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Switch Account / Demo User'), findsOneWidget);
    });
  });
}
