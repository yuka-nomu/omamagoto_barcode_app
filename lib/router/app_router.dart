import 'package:go_router/go_router.dart';
import 'package:omamagoto_barcode_app/screens/barcode_print_screen.dart';
import 'package:omamagoto_barcode_app/screens/checkout_screen.dart';
import 'package:omamagoto_barcode_app/screens/home_screen.dart';
import 'package:omamagoto_barcode_app/screens/product_edit_screen.dart';
import 'package:omamagoto_barcode_app/screens/product_list_screen.dart';
import 'package:omamagoto_barcode_app/screens/scan_screen.dart';
import 'package:omamagoto_barcode_app/screens/settings_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListScreen(),
    ),
    GoRoute(
      path: '/product-edit',
      builder: (context, state) => const ProductEditScreen(),
    ),
    GoRoute(
      path: '/print',
      builder: (context, state) => const BarcodePrintScreen(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
