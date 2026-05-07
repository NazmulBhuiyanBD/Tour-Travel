using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using System.Text;
using System.Threading.Tasks;
using TravelApp.Data;
using TravelApp.Middleware;
using TravelApp.Services;
using TravelApp.Hubs;

AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddSignalR();
builder.Services.AddOpenApi();
builder.Services.AddDbContext<AppDbContext>(options =>
{
    var connectionString =
        Environment.GetEnvironmentVariable("DATABASE_URL")
        ?? builder.Configuration.GetConnectionString("DefaultConnection");

    options.UseNpgsql(connectionString);
});

var jwt = builder.Configuration.GetSection("Jwt");

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,

        ValidIssuer = jwt["Issuer"],
        ValidAudience = jwt["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwt["Key"]))
    };
    options.Events = new JwtBearerEvents
    {
        OnMessageReceived = context =>
        {
            var accessToken = context.Request.Query["access_token"];
            var path = context.HttpContext.Request.Path;
            if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/chathub"))
            {
                context.Token = accessToken;
            }
            return Task.CompletedTask;
        }
    };
});
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<UserService>();
builder.Services.AddScoped<FlightService>();
builder.Services.AddScoped<HotelService>();

builder.Services.AddScoped<TourService>();
builder.Services.AddScoped<BookingService>();
builder.Services.AddScoped<PaymentService>();
builder.Services.AddScoped<JwtService>();
builder.Services.AddScoped<FileService>();
builder.Services.AddScoped<IEmailService, EmailService>();

builder.Services.AddHttpClient<PaymentService>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    // Automatically apply any pending migrations
    Console.WriteLine("Applying database migrations...");
    try {
        context.Database.Migrate();
        Console.WriteLine("Database migrations applied successfully.");
    } catch (Exception ex) {
        Console.WriteLine($"Error applying migrations: {ex.Message}");
    }

    if (!context.Admins.Any())
    {
        context.Admins.Add(new TravelApp.Models.Admin 
        {
             Name = "System Admin",
             Email = "admin@travel.com",
             Password = TravelApp.Services.PasswordHasher.Hash("admin123"),
             Phone = "0000000000"
        });
        context.SaveChanges();
    }
    DbInitializer.Initialize(context);
}

app.UseMiddleware<ExceptionMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.UseStaticFiles();

app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();

app.UseHttpsRedirection();

app.MapControllers();
app.MapHub<ChatHub>("/chathub");

var port = Environment.GetEnvironmentVariable("PORT") ?? "5198";
app.Run($"http://0.0.0.0:{port}");