using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using TravelApp.Data;
using TravelApp.Middleware;
using TravelApp.Services;

var builder = WebApplication.CreateBuilder(args);

// ======================
// ?? SERVICES
// ======================
builder.Services.AddControllers();

// OpenAPI (Swagger alternative in .NET 9)
builder.Services.AddOpenApi();

// ======================
// ?? DATABASE
// ======================
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection")
    )
);

// ======================
// ?? JWT AUTH
// ======================
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
});

// ======================
// ?? CUSTOM SERVICES
// ======================
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<UserService>();
builder.Services.AddScoped<FlightService>();
builder.Services.AddScoped<HotelService>();
builder.Services.AddScoped<VisaService>();
builder.Services.AddScoped<JwtService>();
builder.Services.AddScoped<FileService>();

builder.Services.AddHttpClient<PaymentService>();

// ======================
// ?? CORS
// ======================
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

// ======================
// ?? EXCEPTION MIDDLEWARE
// ======================
app.UseMiddleware<ExceptionMiddleware>();

// ======================
// ?? OPEN API (.NET 9)
// ======================
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

// ======================
// ?? STATIC FILES (for images)
// ======================
app.UseStaticFiles();

// ======================
// ?? CORS
// ======================
app.UseCors("AllowAll");

// ======================
// ?? AUTH
// ======================
app.UseAuthentication();
app.UseAuthorization();

// ======================
app.UseHttpsRedirection();

// ======================
// ?? ROUTES
// ======================
app.MapControllers();

app.Run();