import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteNames {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String transactions = '/transactions';
  static const String addTransaction = '/add-transaction';
  static const String editTransaction = '/edit-transaction/:id';
  static const String categories = '/categories';
  static const String addCategory = '/add-category';
  static const String editCategory = '/edit-category/:id';
  static const String savings = '/savings';
  static const String addSavings = '/add-savings';
  static const String savingsDetail = '/savings/:id';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String budgets = '/budgets';
}

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.login,
  routes: [
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const Scaffold(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const Scaffold(),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const Scaffold(),
    ),
    GoRoute(
      path: RouteNames.transactions,
      builder: (context, state) => const Scaffold(),
    ),
    GoRoute(
      path: RouteNames.addTransaction,
      builder: (context, state) => const Scaffold(),
    ),
    GoRoute(
      path: RouteNames.categories,
      builder: (context, state) => const Scaffold(),
    ),
    GoRoute(
      path: RouteNames.savings,
      builder: (context, state) => const Scaffold(),
    ),
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const Scaffold(),
    ),
    GoRoute(
      path: RouteNames.budgets,
      builder: (context, state) => const Scaffold(),
    ),
  ],
);
