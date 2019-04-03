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
using PolyPaint.API.Auth;
using PolyPaint.API.Hubs;
using PolyPaint.Core;
using PolyPaint.DataAccess.Contexts;
using PolyPaint.DataAccess.Services;

namespace PolyPaint.API
{
    public class Startup
    {
        private readonly string SIGNALR_URL = "/signalr";
        private readonly string SIGNALR_COLLABORATIVE_URL = "/signalr/collaborative";

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
                options.User.AllowedUserNameCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890._-";
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
            services.AddScoped<CanvasService>();

            AuthInitializer.AddJwtBearerAuthentication(services, Configuration, SIGNALR_URL);
            AuthInitializer.AddFacebookAuthentication(services, Configuration);

            services.AddSignalR();
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
                routes.MapHub<CollaborativeHub>(SIGNALR_COLLABORATIVE_URL);
                routes.MapHub<ChatHub>(SIGNALR_URL);
            });
            app.UseMvc();
            app.Run(async context => { await context.Response.WriteAsync("Route not found in PolyPaint API"); });
        }
    }
}
