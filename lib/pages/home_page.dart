// ignore_for_file: avoid_print, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:project_fullstack/widgets/users/carousel_slider.dart';
import 'package:project_fullstack/widgets/app_bar/app_bar_home.dart';
import 'package:project_fullstack/widgets/users/product_recommendation.dart';

class UsersHomePage extends StatefulWidget {
  const UsersHomePage({super.key});

  @override
  _UsersHomePageState createState() => _UsersHomePageState();
}

class _UsersHomePageState extends State<UsersHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        name: 'Selamat Datang',
        image: 'https://placehold.co/40x40/E6E6FA/000000?text=S',
        onAvatarTap: () {
          print('Avatar diketuk!');
        },
      ),

      body: Column(
        children: [
          SizedBox(height: 260, child: const FurnitureCarousel()),
          SizedBox(child: ProductRecommendation()),
        ],
      ),
    );
  }
}
