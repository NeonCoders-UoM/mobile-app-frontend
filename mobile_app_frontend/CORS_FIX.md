# CORS Issue Resolution

## Problem

Your Flutter web app is getting a CORS error when trying to access your .NET backend API. This is a common issue when a web application running on one port (Flutter on `localhost:51443`) tries to access an API on another port (.NET on `192.168.8.186:5039`).

## Root Cause

The browser's security policy blocks cross-origin requests unless the server explicitly allows them through CORS (Cross-Origin Resource Sharing) headers.

## Quick Solution

### Step 1: Add CORS to your .NET Backend

Add this code to your `Program.cs` file:

```csharp
// After var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
builder.Services.AddCors(); // Add this line

var app = builder.Build();

// Before app.UseRouting();
app.UseCors(policy =>
{
    policy.AllowAnyOrigin()
          .AllowAnyMethod()
          .AllowAnyHeader();
});

// ... rest of your configuration
app.UseRouting();
app.MapControllers();
app.Run();
```

### Step 2: Restart Your Backend

1. Stop your .NET application
2. Start it again
3. Make sure it's running on `http://192.168.8.186:5039`

### Step 3: Test the Flutter App

1. Refresh your Flutter web app
2. Navigate to the reminders page
3. The CORS error should be resolved

## Production-Ready CORS Configuration

For production, use a more restrictive CORS policy:

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterApp", policy =>
    {
        policy.WithOrigins("http://localhost:51443") // Your Flutter app URL
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

// Then use it:
app.UseCors("FlutterApp");
```

## Alternative Solutions

### 1. Chrome with Disabled Security (Development Only)

Run Chrome with disabled web security (NOT recommended for production):

```bash
chrome.exe --user-data-dir=/tmp/foo --disable-web-security
```

### 2. Use Flutter Desktop/Mobile

CORS only affects web browsers. Flutter desktop or mobile apps don't have this restriction.

### 3. Set up a Proxy

Configure a proxy server to route requests and avoid CORS issues.

## Verification

After implementing the CORS fix:

1. ✅ No CORS errors in browser console
2. ✅ API calls succeed
3. ✅ Reminders load properly
4. ✅ Create/update/delete operations work

The Flutter app is now properly configured to work with your .NET backend once CORS is enabled!
