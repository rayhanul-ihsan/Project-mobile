# API Service Documentation

## Overview
Struktur code telah dirapikan dengan menambahkan layer service untuk mengelola HTTP requests dengan Authorization header secara otomatis.

## Struktur File

```
lib/
├── services/
│   └── http_service.dart          # HTTP service dengan auto Authorization
├── controllers/
│   ├── auth_controller.dart       # Authentication controller
│   ├── product_controller.dart    # Product management
│   └── user_controller.dart       # User management
└── config/
    └── app_config.dart           # API configuration
```

## HttpService

Service ini mengelola semua HTTP requests dengan Authorization header otomatis.

### Features:
- Auto-inject Authorization Bearer token dari SharedPreferences
- Support untuk public endpoints (requiresAuth: false)
- Support untuk multipart/form-data requests
- Simplified API calls

### Methods:
```dart
HttpService.get(url, {requiresAuth: true})
HttpService.post(url, {body, requiresAuth: true})
HttpService.put(url, {body, requiresAuth: true})
HttpService.delete(url, {requiresAuth: true})
HttpService.multipartRequest(method, url, {requiresAuth: true})
```

## AuthController

### Login
```dart
final authController = AuthController();
final role = await authController.login('username', 'password');

// Response dari server:
// {
//   "status": true,
//   "message": "login successful",
//   "data": {
//     "id": "...",
//     "username": "...",
//     "email": "...",
//     "role": "admin",
//     ...
//   },
//   "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
//   "token_type": "bearer"
// }
```

Token akan disimpan otomatis di SharedPreferences dan digunakan untuk semua request berikutnya.

### Logout
```dart
await authController.logout();
```

### Helper Methods
```dart
// Get current logged in user
final user = await authController.getCurrentUser();

// Get access token
final token = await authController.getAccessToken();

// Check if user is logged in
final isLoggedIn = await authController.isLoggedIn();
```

## ProductController

Semua method menggunakan Authorization header otomatis.

### Upload Image
```dart
final controller = ProductController();
final imagePath = await controller.uploadImage(imageFile);
```

### Add Product
```dart
final response = await controller.submitProduct(
  nama: 'Product Name',
  kategori: 'Category',
  stokAwal: 100,
  harga: 50000,
  status: 'Aktif',
  deskripsi: 'Description',
  image: imagePath,
);
```

### Get Products
```dart
final products = await controller.getProducts(
  order: 'desc',
  orderBy: 'created_at',
  page: 1,
  size: 10,
  search: 'keyword',
  searchBy: ['nama', 'kategori'],
);
```

### Delete Product
```dart
final success = await controller.deleteProduct(productId);
```

## UserController

### Create User (Public - No Auth Required)
```dart
final userController = UserController();
final response = await userController.createUser(
  username: 'newuser',
  email: 'user@email.com',
  password: 'password123',
  phone: '08123456789',
  role: 'user',
  photoProfile: 'path/to/photo',
);
```

### Get Users (Auth Required)
```dart
final users = await userController.getUsers(
  order: 'desc',
  orderBy: 'created_at',
  page: 1,
  size: 10,
  search: 'keyword',
);
```

### Get User By ID (Auth Required)
```dart
final user = await userController.getUserById(userId);
```

### Update User (Auth Required)
```dart
final success = await userController.updateUser(userId, {
  'username': 'updated_username',
  'email': 'updated@email.com',
});
```

### Delete User (Auth Required)
```dart
final success = await userController.deleteUser(userId);
```

## Authorization Flow

1. **Login**: User login menggunakan username/password
   - Server response dengan `access_token`
   - Token disimpan di SharedPreferences

2. **Authenticated Requests**: Semua request selain login dan register user
   - HttpService otomatis mengambil token dari SharedPreferences
   - Token ditambahkan ke header: `Authorization: Bearer {token}`

3. **Logout**:
   - Clear semua data di SharedPreferences
   - User harus login lagi untuk authenticated requests

## Error Handling

Semua controller sudah dilengkapi dengan try-catch untuk error handling:

```dart
try {
  final products = await ProductController().getProducts();
  // Success
} catch (e) {
  // Handle error
  print('Error: $e');
}
```

## Configuration

Update `lib/config/app_config.dart` untuk mengubah API base URL:

```dart
class AppConfig {
  static const bool useLocal = true;
  static const String localHost = 'http://10.0.2.2:8000';
  static const String remoteHost = 'http://your-server.com:8000';

  static String get baseHost => useLocal ? localHost : remoteHost;
  static String get apiBase => '$baseHost/api/v1';
}
```

## Best Practices

1. **Always handle errors**: Wrap calls dalam try-catch
2. **Check authentication**: Gunakan `authController.isLoggedIn()` sebelum navigate ke protected pages
3. **Token expiration**: Implement token refresh jika server support
4. **Logout on 401**: Jika response 401 (Unauthorized), logout user dan redirect ke login page
