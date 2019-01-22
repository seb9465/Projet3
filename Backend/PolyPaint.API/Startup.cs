using System;
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
using PolyPaint.DataAccess.Contexts;
using PolyPaint.DataAccess.Services;
using PolyPaint.Hubs;

namespace PolyPaint.API
{
    public class Startup
    {
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

            };

            services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            }).AddJwtBearer(options =>
            {
                options.Audience = "https://localhost:44300";
                options.ClaimsIssuer = "https://localhost:44300";
                options.Audience = "https://localhost:44300";
                options.Authority = "https://localhost:44300";
                options.TokenValidationParameters = tokenValidationParameters;
                options.SaveToken = true;
                options.Configuration = new OpenIdConnectConfiguration();
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
                routes.MapHub<PolyPaintHub>("/signalr");
            });
            app.UseMvc();
            app.Run(async context => { await context.Response.WriteAsync("Route not found in PolyPaint API"); });
        }
    }
}
