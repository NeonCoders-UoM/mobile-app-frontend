# Backend CORS Configuration Update

## Current Issue

Your Flutter app is trying to connect to `http://localhost:5039/api` but your CORS configuration doesn't include the port your Flutter app is running on.

## Solution: Update Your Backend CORS Configuration

Replace your current CORS configuration in `Program.cs` with this updated version:

```csharp
// --------------------- CORS ---------------------
builder.Services.AddCors(options =>
{
    options.AddPolicy("DevelopmentCors", policy =>
    {
        policy.WithOrigins(
                "http://localhost:3000",         // React web
                "http://localhost:2027",         // Flutter mobile web dev
                "http://127.0.0.1:2027",
                "http://localhost:8081",
                "http://localhost:51443",        // Flutter web default
                "http://127.0.0.1:51443",
                "http://localhost:3000",         // Alternative Flutter port
                "http://127.0.0.1:3000",
                "http://localhost:8080",         // Another common Flutter port
                "http://127.0.0.1:8080",
                "http://localhost:5000",         // Another common port
                "http://127.0.0.1:5000")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials()
              .WithExposedHeaders("Content-Disposition"); // For file downloads
    });

    options.AddPolicy("ProductionCors", policy =>
    {
        policy.WithOrigins(
                "http://localhost:3000",         // React web
                "http://localhost:2027",         // Flutter mobile web dev
                "http://127.0.0.1:2027",
                "http://localhost:8081",
                "http://localhost:51443",        // Flutter web default
                "http://127.0.0.1:51443",
                "https://yourproductionsite.com") // Add your production domain here
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});
```

## Alternative: Allow All Origins (Development Only)

For quick testing, you can temporarily allow all origins:

```csharp
// --------------------- CORS ---------------------
builder.Services.AddCors(options =>
{
    options.AddPolicy("DevelopmentCors", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});
```

## Steps to Fix:

1. **Update your backend's Program.cs** with the CORS configuration above
2. **Restart your backend**: `dotnet run`
3. **Check what port your Flutter app is running on** (look in the terminal where you started Flutter)
4. **Add that port to the CORS configuration** if it's not already there
5. **Refresh your Flutter web app**
6. **Try signing in again**

## Find Your Flutter App Port

When you run `flutter run -d chrome`, look for a line like:
```
The Flutter DevTools debugger and profiler on Chrome is available at:
http://127.0.0.1:XXXXX?uri=http://127.0.0.1:XXXXX/hnABL8qxuoo=/ws
```

The port number (XXXXX) is what you need to add to your CORS configuration.

## Test the Connection

After updating CORS, test by opening your browser and going to:
`http://localhost:5039/swagger`

If you can see the Swagger UI, your backend is running correctly.

The error should be resolved once the CORS configuration includes your Flutter app's port! 