# Quick CORS Fix for Backend Connection

## Immediate Solution

Add this to your .NET backend's `Program.cs` file:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddCors(); // Add this line

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Add CORS before routing
app.UseCors(policy =>
{
    policy.AllowAnyOrigin()
          .AllowAnyMethod()
          .AllowAnyHeader();
});

app.UseRouting();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

## Steps to Fix:

1. **Add the CORS code above to your backend's Program.cs**
2. **Restart your backend server**: `dotnet run`
3. **Refresh your Flutter web app**
4. **Try signing in again**

## Alternative: Test Backend Connection

Open your browser and go to:
`http://localhost:5039/api/Auth/register-customer`

If you see a response (even an error), your backend is running. If you get "Connection refused", your backend is not running.

## If Backend is Not Running:

1. Navigate to your backend project directory
2. Run: `dotnet run`
3. Make sure it starts on port 5039
4. Try the Flutter app again

## If Still Having Issues:

1. Check if port 5039 is available: `netstat -an | findstr :5039`
2. Try a different port in your backend
3. Update the API URL in `lib/core/config/api_config.dart` if needed

The error should be resolved once your backend is running with CORS enabled! 