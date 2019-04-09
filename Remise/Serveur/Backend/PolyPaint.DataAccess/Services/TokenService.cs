using Microsoft.IdentityModel.Tokens;
using PolyPaint.Core;
using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace PolyPaint.DataAccess.Services
{
    public class TokenService
    {
        private const string Secret = "db3OIsj+BXE9NZDy0t8W3TcNekrF+2d/1sFnWG4HnV8TZY30iTOdtVWJG8abWvB1GlOgJuQZdcF2Luqm/hccMw==";
        public string GenerateToken(ApplicationUser user, int expireMinutes = 999999999)
        {
            byte[] symmetricKey = Convert.FromBase64String(Secret);
            JwtSecurityTokenHandler tokenHandler = new JwtSecurityTokenHandler();

            DateTime now = DateTime.UtcNow;
            SecurityTokenDescriptor tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]{
                        new Claim(ClaimTypes.Name, user.UserName),
                        new Claim(ClaimTypes.NameIdentifier, user.Id),
                        new Claim(ClaimTypes.Surname, user.FirstName)
                    }),
                Audience = "https://polypaint.me",
                Issuer = "https://polypaint.me",
                IssuedAt = DateTime.Now,
                Expires = now.AddMinutes(Convert.ToInt32(expireMinutes)),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(symmetricKey), SecurityAlgorithms.HmacSha256Signature)
            };

            SecurityToken stoken = tokenHandler.CreateJwtSecurityToken(tokenDescriptor);
            string token = tokenHandler.WriteToken(stoken);
            return token;
        }
        
        public string GenerateTokenFacebook(ApplicationUser user, int expireMinutes = 999999999)
        {
            byte[] symmetricKey = Convert.FromBase64String(Secret);
            JwtSecurityTokenHandler tokenHandler = new JwtSecurityTokenHandler();

            DateTime now = DateTime.UtcNow;
            SecurityTokenDescriptor tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]{
                        new Claim(ClaimTypes.Name, user.UserName),
                        new Claim(ClaimTypes.NameIdentifier, user.Id),
                        new Claim(ClaimTypes.Surname, user.FirstName)
                    }),
                Audience = "https://polypaint.me",
                Issuer = "https://polypaint.me",
                IssuedAt = DateTime.Now,
                Expires = now.AddMinutes(Convert.ToInt32(expireMinutes)),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(symmetricKey), SecurityAlgorithms.HmacSha256Signature)
            };

            SecurityToken stoken = tokenHandler.CreateJwtSecurityToken(tokenDescriptor);
            string token = tokenHandler.WriteToken(stoken);
            return token;
        }
    }


}
