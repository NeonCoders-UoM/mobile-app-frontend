# Service History Backend Integration

This document outlines the backend integration for the Service History feature in the mobile app frontend.

## 🏗️ Backend API Requirements

The Service History feature expects the following API endpoints to be implemented in your .NET backend:

### Base Configuration

- **Base URL**: `http://localhost:5039/api` (configured in `lib/core/config/api_config.dart`)
- **Content-Type**: `application/json`
- **Timeout**: 30 seconds

### Required Endpoints

#### 1. Get All Service History

```
GET /api/ServiceHistory
```

**Response**: Array of service history records

#### 2. Get Service History by Vehicle ID

```
GET /api/ServiceHistory/Vehicle/{vehicleId}
```

**Parameters**:

- `vehicleId`: Integer - The vehicle ID

**Response**: Array of service history records for the specific vehicle

#### 3. Get Service History by ID

```
GET /api/ServiceHistory/{serviceId}
```

**Parameters**:

- `serviceId`: Integer - The service record ID

**Response**: Single service history record

#### 4. Create Service History Record

```
POST /api/ServiceHistory
```

**Request Body**: ServiceHistory object (JSON)
**Response**: Created service history record with assigned ID

#### 5. Update Service History Record

```
PUT /api/ServiceHistory/{serviceId}
```

**Parameters**:

- `serviceId`: Integer - The service record ID

**Request Body**: Updated ServiceHistory object (JSON)
**Response**: Updated service history record

#### 6. Delete Service History Record

```
DELETE /api/ServiceHistory/{serviceId}
```

**Parameters**:

- `serviceId`: Integer - The service record ID

**Response**: 200/204 status code

## 📋 Data Model

The frontend expects the following JSON structure for Service History records:

```json
{
  "id": 1,
  "vehicleId": 1,
  "serviceTitle": "Oil Change",
  "serviceDescription": "Regular oil change and filter replacement",
  "serviceDate": "2025-01-15T00:00:00Z",
  "serviceProvider": "Local Garage",
  "location": "Colombo",
  "cost": 5000.0,
  "status": "Completed",
  "isVerified": true,
  "notes": "Used synthetic oil",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T10:30:00Z"
}
```

### Field Descriptions

| Field                | Type     | Required            | Description                                      |
| -------------------- | -------- | ------------------- | ------------------------------------------------ |
| `id`                 | Integer  | No (auto-generated) | Unique identifier for the service record         |
| `vehicleId`          | Integer  | Yes                 | ID of the vehicle this service belongs to        |
| `serviceTitle`       | String   | Yes                 | Title/name of the service performed              |
| `serviceDescription` | String   | Yes                 | Detailed description of the service              |
| `serviceDate`        | DateTime | Yes                 | Date when the service was performed              |
| `serviceProvider`    | String   | Yes                 | Name of the service provider/garage              |
| `location`           | String   | Yes                 | Location where service was performed             |
| `cost`               | Decimal  | No                  | Cost of the service (optional)                   |
| `status`             | String   | Yes                 | Status of service (e.g., "Completed", "Pending") |
| `isVerified`         | Boolean  | Yes                 | Whether this is a verified service record        |
| `notes`              | String   | No                  | Additional notes about the service               |
| `createdAt`          | DateTime | Yes                 | When the record was created                      |
| `updatedAt`          | DateTime | No                  | When the record was last updated                 |

## 🔧 Backend Implementation Example (.NET)

### Service History Model

```csharp
public class ServiceHistory
{
    public int Id { get; set; }
    public int VehicleId { get; set; }
    public string ServiceTitle { get; set; } = string.Empty;
    public string ServiceDescription { get; set; } = string.Empty;
    public DateTime ServiceDate { get; set; }
    public string ServiceProvider { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public decimal? Cost { get; set; }
    public string Status { get; set; } = "Completed";
    public bool IsVerified { get; set; } = true;
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}
```

### Controller Example

```csharp
[ApiController]
[Route("api/[controller]")]
public class ServiceHistoryController : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<ServiceHistory>>> GetAll()
    {
        // Return all service history records
    }

    [HttpGet("Vehicle/{vehicleId}")]
    public async Task<ActionResult<IEnumerable<ServiceHistory>>> GetByVehicle(int vehicleId)
    {
        // Return service history for specific vehicle
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ServiceHistory>> GetById(int id)
    {
        // Return specific service history record
    }

    [HttpPost]
    public async Task<ActionResult<ServiceHistory>> Create(ServiceHistory serviceHistory)
    {
        // Create new service history record
        serviceHistory.CreatedAt = DateTime.UtcNow;
        // Save to database
        return CreatedAtAction(nameof(GetById), new { id = serviceHistory.Id }, serviceHistory);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, ServiceHistory serviceHistory)
    {
        // Update existing service history record
        serviceHistory.UpdatedAt = DateTime.UtcNow;
        // Save to database
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        // Delete service history record
        return NoContent();
    }
}
```

## 🧪 Testing the Integration

### Run the Test Script

```bash
cd mobile_app_frontend
dart run test_service_history_backend.dart
```

This will test:

1. Backend connection
2. Getting service history records
3. Adding unverified services (local)
4. Adding verified services (API)
5. Service statistics
6. Direct API endpoint tests

### Manual Testing Steps

1. **Start your .NET Backend**

   ```bash
   # Make sure your backend is running on http://localhost:5039
   dotnet run
   ```

2. **Test in Flutter App**

   - Navigate to Service History page
   - Check connection status indicator
   - Try adding an unverified service
   - Verify records appear in the list

3. **Check Network Tab**
   - Open browser dev tools
   - Monitor API calls when using the app
   - Verify correct endpoints are being called

## 🔄 Data Flow

### Verified Services (Backend)

```
Flutter App → HTTP Request → .NET API → Database → Response → Flutter App
```

### Unverified Services (Local)

```
Flutter App → Local Storage → Display in UI
```

### Combined Display

```
API Data + Local Data → Combined List → Sorted by Date → UI Display
```

## 🛠️ Configuration

### Update API Base URL

Edit `lib/core/config/api_config.dart`:

```dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

### Environment-Specific URLs

```dart
// Development
static const String devBaseUrl = 'http://localhost:5039/api';

// Staging
static const String stagingBaseUrl = 'https://staging-api.your-domain.com/api';

// Production
static const String prodBaseUrl = 'https://api.your-domain.com/api';
```

## 🚨 Error Handling

The frontend handles the following scenarios:

- **Backend Offline**: Falls back to local data only
- **Network Timeout**: Shows error message, retries available
- **API Errors**: Logs error details, shows user-friendly messages
- **Invalid Data**: Validates responses before processing

## 🔒 Security Considerations

1. **CORS Configuration**: Ensure your backend allows requests from the Flutter web app
2. **Authentication**: Add authentication headers if required
3. **Data Validation**: Validate all input data on the backend
4. **Rate Limiting**: Implement rate limiting on your API endpoints

## 📈 Future Enhancements

1. **Offline Sync**: Sync unverified services to backend when connection is restored
2. **Real-time Updates**: Use WebSockets or polling for live updates
3. **File Uploads**: Support uploading service receipts/photos
4. **Push Notifications**: Notify users of service updates
5. **Data Encryption**: Encrypt sensitive service data

## 🐛 Troubleshooting

### Common Issues

1. **CORS Errors**

   - Configure CORS in your .NET backend
   - See `CORS_FIX.md` for detailed instructions

2. **Connection Timeout**

   - Check if backend is running
   - Verify API base URL is correct
   - Check network connectivity

3. **404 Errors**

   - Verify endpoint URLs match backend routes
   - Check controller and action names

4. **Data Format Issues**
   - Verify JSON field names match model properties
   - Check date format compatibility
   - Ensure numeric fields are properly typed

### Debug Commands

```bash
# Test direct API access
curl -X GET "http://localhost:5039/api/ServiceHistory/Vehicle/1" -H "Accept: application/json"

# Check if backend is running
curl -X GET "http://localhost:5039/api/ServiceHistory" -H "Accept: application/json"
```

## 📞 Support

If you encounter issues with the backend integration:

1. Check the test script output for specific error details
2. Verify your backend implementation matches the expected endpoints
3. Review the browser network tab for API call details
4. Check backend logs for server-side errors
