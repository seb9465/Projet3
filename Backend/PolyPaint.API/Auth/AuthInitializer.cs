using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;

namespace PolyPaint.API.Auth
{
    public static class AuthInitializer
    {
        public static void AddJwtBearerAuthentication(
            IServiceCollection services,
            IConfiguration configuration,
            string signalrUrl)
        {
            var signingKey = new SymmetricSecurityKey(Convert.FromBase64String(configuration.GetSection("Token:Secret").Value));

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
                        if (!string.IsNullOrEmpty(accessToken) && (path.StartsWithSegments(signalrUrl)))
                        {
                            // Read the token out of the query string
                            context.Token = accessToken;
                        }
                        return Task.CompletedTask;
                    }
                };
            });
        }

        public static void AddFacebookAuthentication(IServiceCollection services, IConfiguration configuration)
        {
            services.AddAuthentication().AddFacebook(facebookOptions =>
            {
                facebookOptions.AppId = configuration["Facebook:AppId"];
                facebookOptions.AppSecret = configuration["Facebook:Secret"];
                facebookOptions.SaveTokens = true;
            });
        }
    }
}