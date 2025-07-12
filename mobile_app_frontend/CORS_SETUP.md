# .NET Backend CORS Configuration

To fix the CORS issue, you need to add CORS configuration to your .NET backend. Here's what you need to add:

## 1. Add CORS to Program.cs (or Startup.cs for older versions)

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// Add CORS services
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterApp", policy =>
    {
        policy.WithOrigins(
                "http://localhost:51443",  // Flutter web debug port
                "http://localhost:3000",   // Alternative Flutter port
                "http://127.0.0.1:51443",  // Alternative localhost
                "http://127.0.0.1:3000"
            )
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
    });

    // Alternative: Allow all origins during development (less secure)
    options.AddPolicy("DevelopmentCors", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();

    // Use permissive CORS in development
    app.UseCors("DevelopmentCors");
}
else
{
    // Use restrictive CORS in production
    app.UseCors("FlutterApp");
}

app.UseHttpsRedirection();
app.UseRouting();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

## 2. Alternative Configuration for Startup.cs (if using older .NET)

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddControllers();

    // Add CORS
    services.AddCors(options =>
    {
        options.AddPolicy("FlutterApp", policy =>
        {
            policy.WithOrigins("http://localhost:51443", "http://localhost:3000")
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  .AllowCredentials();
        });
    });
}

public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    if (env.IsDevelopment())
    {
        app.UseDeveloperExceptionPage();
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    app.UseRouting();

    // Enable CORS
    app.UseCors("FlutterApp");

    app.UseAuthorization();
    app.UseEndpoints(endpoints =>
    {
        endpoints.MapControllers();
    });
}
```

## 3. Controller-Level CORS (Alternative)

If you prefer to enable CORS only for specific controllers, add this attribute to your ServiceRemindersController:

```csharp
[EnableCors("FlutterApp")]
[Route("api/[controller]")]
[ApiController]
public class ServiceRemindersController : ControllerBase
{
    // ... your existing controller code
}
```

## 4. Quick Fix for Development

For immediate testing, you can add this minimal CORS configuration:

```csharp
// In Program.cs or Startup.cs ConfigureServices
builder.Services.AddCors();

// In Configure method (before UseRouting())
app.UseCors(policy =>
{
    policy.AllowAnyOrigin()
          .AllowAnyMethod()
          .AllowAnyHeader();
});
```

## Security Notes

- **Development**: Use `AllowAnyOrigin()` for easy testing
- **Production**: Always specify exact origins for security
- **Credentials**: Only use `AllowCredentials()` if you need to send cookies/auth headers
- **Headers**: Specify exact headers in production instead of `AllowAnyHeader()`

## Testing the Fix

After adding CORS configuration:

1. Restart your .NET backend
2. Refresh your Flutter web app
3. Check the browser console for any remaining CORS errors
4. Test the reminder functionality

The CORS error should be resolved and your Flutter app should be able to communicate with the .NET backend successfully.
