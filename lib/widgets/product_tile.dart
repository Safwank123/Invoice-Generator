import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final ValueChanged<bool?>? onChanged;

  const ProductTile({super.key, required this.product, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: product.isSelected,
      title: Text(product.name),
      subtitle: Text("₹${product.price}"),
      onChanged: onChanged,
    );
  }
}
