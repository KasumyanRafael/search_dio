import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
//import 'package:flutter_education/models/products_model.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const SearchPage(),
    );
  }
}
//models
class ProductModel {
  final int id;
  final String title;
  final String description;
  final int price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;
  // final List<String> images;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'] as int,
      brand: json['brand'] as String,
      category: json['category'] as String,
      thumbnail: json['thumbnail'] as String,
      images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }
}

class ProductsModel {
  final List<ProductModel> products;

  ProductsModel({required this.products});

  factory ProductsModel.fromJson(Map<String, dynamic> json) {
    return ProductsModel(
        products: (json['products'] as List<dynamic>)
            .map((product) => ProductModel.fromJson(product as Map<String, dynamic>))
            .toList());
  }
}

//pages
enum SearchStatus { initial, loading, success, failure }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final Dio _dio;
  SearchStatus _searchStatus = SearchStatus.initial;
  List<ProductModel> products = [];

  @override
  initState() {
    _dio = Dio();
    super.initState();
  }

  Future<void> searchProducts(String searchValue) async {
    if (searchValue.isEmpty) {
      setState(() {
        _searchStatus = SearchStatus.initial;
      });
      return;
    }
    setState(() {
      _searchStatus = SearchStatus.loading;
    });

    try {
      final result = await _dio.get('https://dummyjson.com/products/search?q=$searchValue');
      setState(() {
        products = ProductsModel.fromJson(result.data as Map<String, dynamic>).products;
        _searchStatus = SearchStatus.success;
      });
    } catch (error) {
      setState(() {
        _searchStatus = SearchStatus.failure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Поиск продуктов'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => searchProducts(value),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(child: Builder(builder: (context) {
              switch (_searchStatus) {
                case SearchStatus.initial:
                  return const Center(child: Text('Начните поиск'));
                case SearchStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case SearchStatus.success:
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) => ListItem(product: products[index]),
                  );
                case SearchStatus.failure:
                  return const Center(child: Text('Произошла ошибка'));
              }
            })),
          ],
        ),
      ),
    );
  }
}

//widgets
class ListItem extends StatelessWidget {
  final ProductModel product;
  const ListItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      height: 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
              image: NetworkImage(product.thumbnail),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            maxLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 36),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            product.description,
            maxLines: 3,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}


