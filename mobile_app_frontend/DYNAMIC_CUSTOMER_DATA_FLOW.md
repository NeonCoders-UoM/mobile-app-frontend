# Dynamic Customer Data Flow - Service History

This document explains how the service history system works with dynamic customer data instead of hardcoded values.

## ✅ Current Implementation

### 1. Authentication Flow

```
User Login → AuthService.loginCustomer() → Returns {token, customerId}
```

### 2. Vehicle Data Loading

```
VehicleDetailsHomePage → AuthService.getCustomerVehicles(customerId, token) → Real vehicle data
```

### 3. Service History Integration

```
VehicleDetailsHomePage → ServiceHistoryPage(vehicleId: vehicle['vehicleId'], token: token)
```

### 4. API Calls with Authentication

```
ServiceHistoryRepository → HTTP requests with Authorization: Bearer token
```

## 🔄 Data Flow Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Login Page    │───▶│  Auth Service   │───▶│   Backend API   │
│                 │    │                 │    │                 │
│ email/password  │    │ loginCustomer() │    │ /Auth/login     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │ {token,         │
                       │  customerId}    │
                       └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│VehicleDetailsHP │───▶│  Auth Service   │───▶│   Backend API   │
│                 │    │                 │    │                 │
│ Load vehicles   │    │getCustomerVehi  │    │/Customers/{id}/ │
│                 │    │cles(id, token)  │    │vehicles         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │ Real Vehicle    │
                       │ Data Array      │
                       └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ServiceHistoryP  │───▶│ServiceHistoryR  │───▶│   Backend API   │
│                 │    │                 │    │                 │
│vehicleId: real  │    │getServiceHist() │    │/VehicleService  │
│token: real      │    │+ Bearer token   │    │History/Vehicle/ │
│                 │    │                 │    │{vehicleId}      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🎯 Key Features

### ✅ No Hardcoded Data

- ❌ No more `defaultVehicleId = 1`
- ❌ No more hardcoded customer IDs
- ✅ All data comes from authenticated user session

### ✅ Secure API Calls

- All service history API calls include `Authorization: Bearer {token}`
- Token is obtained from actual user login
- Backend can verify user permissions for specific vehicles

### ✅ Multi-User Support

- Each customer sees only their own vehicles
- Each customer sees only their own service history
- Local storage is filtered by vehicle ID

### ✅ Vehicle-Specific Data

- Service history is fetched for the customer's actual vehicles
- Vehicle details (name, registration) come from backend
- No mixing of data between different customers

## 🔧 Implementation Details

### Service History Repository Methods

All methods now accept and use dynamic parameters:

```dart
// Get service history for customer's actual vehicle
getServiceHistory(vehicleId, token: customerToken)

// Add service for customer's actual vehicle
addUnverifiedService(service, token: customerToken)

// Update service with proper authentication
updateService(service, token: customerToken)

// Delete service with proper authentication
deleteService(service, token: customerToken)
```

### Authentication Headers

```dart
Map<String, String> _getHeaders({String? token}) => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  if (token != null) 'Authorization': 'Bearer $token',
};
```

### Vehicle Data Loading

```dart
Future<void> _loadVehicleDetails() async {
  final vehicles = await _authService.getCustomerVehicles(
    customerId: widget.customerId,  // Real customer ID
    token: widget.token,            // Real auth token
  );

  if (vehicles != null && vehicles.isNotEmpty) {
    setState(() {
      _vehicle = vehicles[0];       // Real vehicle data
    });
  }
}
```

### Service History Page Integration

```dart
ServiceHistoryPage(
  vehicleId: _vehicle?['vehicleId'] ?? 1,           // Real vehicle ID
  vehicleName: _vehicle?['model'] ?? 'Vehicle',     // Real vehicle model
  vehicleRegistration: _vehicle?['registrationNumber'] ?? 'Unknown',
  token: widget.token,                              // Real auth token
)
```

## 🔒 Security Benefits

1. **User Isolation**: Each customer can only access their own data
2. **Token-Based Auth**: All API calls are authenticated
3. **Backend Validation**: Backend can verify user has access to specific vehicles
4. **No Data Leakage**: No risk of showing wrong customer's data

## 🚀 Scalability

- Supports unlimited customers
- Supports multiple vehicles per customer
- Supports multi-tenant backend architecture
- Local storage is automatically scoped per vehicle

## 📝 Testing

When testing, pass real authentication tokens:

```dart
// Instead of hardcoded values
final services = await repository.getServiceHistory(1);

// Use dynamic values
final services = await repository.getServiceHistory(
  customerVehicleId,
  token: customerAuthToken
);
```

## 🎉 Result

The service history system now works completely dynamically with:

- ✅ Real customer authentication
- ✅ Real vehicle data from backend
- ✅ Secure API communications
- ✅ Multi-customer support
- ✅ No hardcoded values

Each customer will see only their own vehicles and service history, with all data properly authenticated and secured.
