import 'package:flutter/material.dart';

import '../database_helper.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> products = [];

  Future<void> loadProducts() async {
    final data = await DatabaseHelper.instance.getProducts();

    setState(() {
      products = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: products.isEmpty
          ? const Center(child: Text('No Products Found'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(product['name']),
                    subtitle: Text(
                      'Price: \$${product['price']}   |   Quantity: ${product['quantity']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await DatabaseHelper.instance.deleteProduct(
                          product['id'],
                        );

                        await loadProducts();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product Deleted Successfully'),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
