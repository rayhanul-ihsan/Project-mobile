# Changelog - API Structure Refactoring

## Perubahan yang Dilakukan

### 1. **Dibuat HttpService** (`lib/services/http_service.dart`)
Service baru untuk mengelola semua HTTP requests dengan fitur:
- ✅ Auto-inject Authorization header untuk authenticated requests
- ✅ Support untuk public endpoints (login, register) tanpa Authorization
- ✅ Auto-clear token saat response 401 (Unauthorized)
- ✅ Support untuk multipart/form-data (upload image)
- ✅ Consistent error handling

### 2. **Refactor AuthController** (`lib/controllers/auth_controller.dart`)
**Sebelum:**
```dart
// Manual HTTP call dengan headers
final response = await http.post(
  Uri.parse('$usersBase/login'),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({"username": username, "password": password}),
);
```

**Sesudah:**
```dart
// Menggunakan HttpService dengan requiresAuth: false untuk login
final response = await HttpService.post(
  url,
  body: {"username": username, "password": password},
  requiresAuth: false, // Login tidak butuh token
);
```

**Fitur Baru:**
- ✅ `getCurrentUser()` - Get current logged in user
- ✅ `getAccessToken()` - Get access token
- ✅ `isLoggedIn()` - Check authentication status
- ✅ Cleaner logout dengan `prefs.clear()`

### 3. **Refactor ProductController** (`lib/controllers/product_controller.dart`)
**Sebelum:**
```dart
// Manual manage token untuk setiap request
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('access_token');
final headers = <String, String>{
  "Content-Type": "application/json",
  if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
};
final response = await http.post(url, headers: headers, body: body);
```

**Sesudah:**
```dart
// HttpService otomatis handle Authorization
final response = await HttpService.post(url, body: body);
// Token otomatis ditambahkan ke header
```

**Semua Method Update:**
- ✅ `uploadImage()` - Auto Authorization
- ✅ `submitProduct()` - Auto Authorization
- ✅ `getProducts()` - Auto Authorization
- ✅ `deleteProduct()` - Auto Authorization

### 4. **Dibuat UserController** (`lib/controllers/user_controller.dart`)
Controller baru untuk user management dengan Authorization:
- ✅ `createUser()` - Public endpoint (requiresAuth: false)
- ✅ `getUsers()` - Protected endpoint (auto Authorization)
- ✅ `getUserById()` - Protected endpoint
- ✅ `updateUser()` - Protected endpoint
- ✅ `deleteUser()` - Protected endpoint

### 5. **Dokumentasi API** (`lib/services/README_API.md`)
Dokumentasi lengkap tentang:
- ✅ Struktur file
- ✅ Cara penggunaan setiap controller
- ✅ Authorization flow
- ✅ Error handling
- ✅ Best practices

## Authorization Flow

### 1. Login
```
User Input (username, password)
        ↓
  POST /api/v1/users/login
  (No Authorization header)
        ↓
  Response: {
    "access_token": "eyJhbGci...",
    "data": {...}
  }
        ↓
  Save to SharedPreferences
```

### 2. Authenticated Requests
```
Any API Call
        ↓
  HttpService check requiresAuth
        ↓
  Get token from SharedPreferences
        ↓
  Add header: "Authorization: Bearer {token}"
        ↓
  Send Request
        ↓
  If 401: Auto clear token & logout
```

### 3. Logout
```
User Logout
        ↓
  Clear SharedPreferences
        ↓
  All tokens removed
```

## Keuntungan Struktur Baru

### 1. **DRY (Don't Repeat Yourself)**
- Tidak perlu copy-paste code untuk Authorization di setiap controller
- Satu tempat untuk manage HTTP logic

### 2. **Maintainability**
- Mudah update logic Authorization (cukup di HttpService)
- Mudah add new endpoints (tinggal call HttpService method)

### 3. **Security**
- Auto handle 401 responses
- Consistent token management
- Clear separation antara public & protected endpoints

### 4. **Clean Code**
- Controller lebih readable
- Less boilerplate code
- Clear intention dengan parameter `requiresAuth`

## Migration Guide

Jika ada code lama yang perlu diupdate:

### Update HTTP Calls
**Lama:**
```dart
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('access_token');
final response = await http.post(
  url,
  headers: {
    "Content-Type": "application/json",
    if (token != null) "Authorization": "Bearer $token",
  },
  body: jsonEncode(data),
);
```

**Baru:**
```dart
final response = await HttpService.post(url, body: data);
```

### Update Multipart Requests
**Lama:**
```dart
var request = http.MultipartRequest('POST', url);
final token = prefs.getString('access_token');
if (token != null) {
  request.headers['Authorization'] = 'Bearer $token';
}
```

**Baru:**
```dart
final request = await HttpService.multipartRequest('POST', url);
// Authorization otomatis ditambahkan
```

## Testing

Untuk test Authorization:
1. Login dengan user valid
2. Coba akses protected endpoints → harus berhasil
3. Logout
4. Coba akses protected endpoints → harus redirect ke login

## Next Steps

Improvements yang bisa ditambahkan:
- [ ] Token refresh mechanism
- [ ] Request retry on token refresh
- [ ] Better error messages
- [ ] Request logging untuk debugging
- [ ] Request timeout handling
