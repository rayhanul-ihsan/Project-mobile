// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:project_fullstack/controllers/auth_controller.dart';
import 'package:project_fullstack/controllers/product_controller.dart';
import 'package:project_fullstack/models/product_model.dart';
import 'package:project_fullstack/routes/app_routes.dart';
import 'package:project_fullstack/widgets/app_bar/components/app_bar_menu_item.dart';
import 'package:project_fullstack/widgets/filter/widget_filter_bar_v2.dart';
import 'package:project_fullstack/widgets/admin/products/features/list_product/product_card.dart';
import 'package:project_fullstack/widgets/app_bar/app_bar_custom_search.dart';
import 'package:project_fullstack/widgets/widget_floating_button.dart';

class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  bool isLoading = true;
  String selectedOrder = 'desc';
  String selectedFilter = 'created_at';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      final result = await ProductController().getProducts(
        order: selectedOrder,
        orderBy: selectedFilter,
      );
      setState(() {
        products = result;
        filteredProducts = result;
      });
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final kategoriMatch = p.category.toLowerCase().contains(query);
        return nameMatch || kategoriMatch;
      }).toList();
    });
  }

  void _onFilterChange(String filter) {
    setState(() {
      selectedFilter = filter == 'Nama Produk'
          ? 'name'
          : filter == 'Harga Produk'
          ? 'price'
          : filter == 'Kategori'
          ? 'category'
          : 'status';
    });
    _loadProducts();
  }

  void _onSortChange(String order) {
    setState(() {
      selectedOrder = order.toLowerCase();
    });
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          const SizedBox(height: 44),
          AppBarCustomSearch(
            hintText: 'Cari produk...',
            controller: _searchController,
            menuItems: [
              AppBarMenuItem(
                icon: PhosphorIconsBold.usersThree,
                text: 'Management User',
                onTap: () => Navigator.pushNamed(context, AppRoutes.userList),
              ),
              AppBarMenuItem(
                icon: PhosphorIconsBold.signOut,
                text: 'Logout',
                onTap: () async {
                  await AuthController().logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          WidgetFilterBarV2(
            onFilterChange: _onFilterChange,
            onSortChange: _onSortChange,
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final p = filteredProducts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ProductCard(product: p),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: const WidgetFloatingButton(),
    );
  }
}
