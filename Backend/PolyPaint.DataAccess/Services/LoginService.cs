using Microsoft.AspNetCore.Identity;
using PolyPaint.Core;
using PolyPaint.Core.ViewModels;
using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
namespace PolyPaint.DataAccess.Services
{
    public class LoginService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly TokenService _tokenService;
        public LoginService(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            TokenService tokenService)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _tokenService = tokenService;
        }
        public async Task<string> Login(LoginViewModel loginViewModel)
        {
            ApplicationUser user = null;
            // TODO: REGEX?
            if (loginViewModel.Username.Contains("@"))
            {
                user = await _userManager.FindByEmailAsync(loginViewModel.Username);
            }
            else
            {
                user = await _userManager.FindByNameAsync(loginViewModel.Username);
            }

            bool isLoginSuccesful = await _userManager.CheckPasswordAsync(user, loginViewModel.Password);
            string token = null;
            if (isLoginSuccesful)
            {
                token = _tokenService.GenerateToken(user);
            }

            return token;
        }

        public async Task<string> HandleFacebookLogin(ExternalLoginInfo info)
        {
            SignInResult existingFacebookLogin = await _signInManager
                .ExternalLoginSignInAsync(info.LoginProvider, info.ProviderKey, isPersistent: true);
            string token = null;
            if (!existingFacebookLogin.Succeeded)
            {
                string email = info.Principal.FindFirstValue(ClaimTypes.Email);
                ApplicationUser currentUser = await _userManager.FindByEmailAsync(email);

                if (currentUser == null)
                {
                    ApplicationUser newUser = new ApplicationUser
                    {
                        FirstName = info.Principal.FindFirstValue(ClaimTypes.Email),
                        UserName = info.Principal.FindFirstValue(ClaimTypes.NameIdentifier),
                        Email = email,
                    };
                    IdentityResult createResult = await _userManager.CreateAsync(newUser);
                    if (createResult.Succeeded)
                    {
                        currentUser = newUser;
                    }
                    else
                    {
                        throw new Exception(createResult.Errors.Select(e => e.Description).Aggregate((errors, error) => $"{errors}, {error}"));
                    }
                }

                IdentityResult linkingFacebook = await _userManager.AddLoginAsync(currentUser, info);
                await _signInManager.SignInAsync(currentUser, isPersistent: false);
                token = _tokenService.GenerateToken(currentUser);
                return token;
            }
            else
            {
                //string email = info.Principal.FindFirstValue(ClaimTypes.Email);
                //token = _tokenService.GenerateToken(email);
                return token;
            }
        }
    }
}
