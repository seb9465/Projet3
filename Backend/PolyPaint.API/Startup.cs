using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;
using PolyPaint.API.Hubs;
using PolyPaint.Core;
using PolyPaint.DataAccess.Contexts;
using PolyPaint.DataAccess.Services;

namespace PolyPaint.API
{
    public class Startup
    {
        private readonly string SIGNALR_URL = "/signalr";
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_2);
            services.AddIdentity<ApplicationUser, IdentityRole>(options =>
            {
                options.User.RequireUniqueEmail = true;
            })
            .AddEntityFrameworkStores<PolyPaintContext>()
            .AddDefaultTokenProviders();

            services.AddDbContext<PolyPaintContext>(options =>
                    options.UseSqlServer(Configuration.GetConnectionString("DefaultConnection")));

            services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
            services.AddScoped<TokenService>();
            services.AddScoped<RegisterService>();
            services.AddScoped<LoginService>();
            services.AddScoped<UserService>();

            AddJwtBearerAuthentication(services);

            services.AddAuthentication().AddFacebook(facebookOptions =>
            {
                facebookOptions.AppId = Configuration["Facebook:AppId"];
                facebookOptions.AppSecret = Configuration["Facebook:Secret"];
                facebookOptions.SaveTokens = true;
            });

            services.AddSignalR();
        }

        private void AddJwtBearerAuthentication(IServiceCollection services)
        {
            var signingKey = new SymmetricSecurityKey(Convert.FromBase64String(Configuration.GetSection("Token:Secret").Value));

            var tokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = signingKey,
                ValidateIssuer = false,
                ValidateAudience = false,
                ValidateLifetime = true,
                RequireExpirationTime = false
            };

            services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(options =>
            {
                options.Audience = "https://localhost:44300";
                options.ClaimsIssuer = "https://localhost:44300";
                options.Audience = "https://localhost:44300";
                options.Authority = "https://localhost:44300";
                options.TokenValidationParameters = tokenValidationParameters;
                options.SaveToken = true;
                options.Configuration = new OpenIdConnectConfiguration();
                // for signalr
                options.Events = new JwtBearerEvents
                {
                    OnMessageReceived = context =>
                    {
                        var accessToken = context.Request.Query["access_token"];

                        // If the request is for our hub...
                        var path = context.HttpContext.Request.Path;
                        if (!string.IsNullOrEmpty(accessToken) && (path.StartsWithSegments(SIGNALR_URL)))
                        {
                            // Read the token out of the query string
                            context.Token = accessToken;
                        }
                        return Task.CompletedTask;
                    }
                };
            });

        }

        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseAuthentication();
            app.UseSignalR(routes =>
            {
                routes.MapHub<PolyPaintHub>(SIGNALR_URL);
            });
            app.UseMvc();
            app.Run(async context => { await context.Response.WriteAsync("Route not found in PolyPaint API"); });
        }
    }
}
