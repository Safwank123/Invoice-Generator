import '../models/product_model.dart';

class InvoiceViewModel {
  final List<Product> products = [
    Product(name: "Product A", price: 100),
    Product(name: "Product B", price: 200),
    Product(name: "Product C", price: 150),
    Product(name: "Product D", price: 250),
    Product(name: "Product E", price: 300),
  ];

  String userName = "";
  String userEmail = "";

  List<Product> get selectedProducts =>
      products.where((product) => product.isSelected).toList();

  double get total =>
      selectedProducts.fold(0, (sum, item) => sum + item.price);

  bool isValid() {
    return userName.isNotEmpty &&
        userEmail.isNotEmpty &&
        selectedProducts.isNotEmpty;
  }
}
