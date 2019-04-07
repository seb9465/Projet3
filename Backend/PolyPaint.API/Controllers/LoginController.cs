using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PolyPaint.Core;
using PolyPaint.Core.ViewModels;
using PolyPaint.DataAccess.Services;

namespace PolyPaint.API.Controllers
{
    [Route("api/[controller]")]
    public class LoginController : ControllerBase
    {
        private readonly LoginService _loginService;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public LoginController(LoginService loginService,
            SignInManager<ApplicationUser> signInManager,
            IHttpContextAccessor httpContextAccessor)
        {
            _loginService = loginService;
            _signInManager = signInManager;
            _httpContextAccessor = httpContextAccessor;
        }
        [HttpPost]
        public async Task<IActionResult> Login([FromBody]LoginViewModel loginViewModel)
        {
            String token = "";
            try {
            token = await _loginService.Login(loginViewModel);
            } catch(Exception e) {
                return BadRequest(e.Message);
            }
            if (ModelState.IsValid)
            {
                if (token != null)
                {
                    return Ok(token);
                } else {
                    return BadRequest();
}
            }
            else
            {
                var errorList = ModelState.ToDictionary(
                state => state.Key,
                state => state.Value.Errors.Select(e => e.ErrorMessage).ToArray());
                return BadRequest(errorList);
            }
        }

        [HttpGet]
        public IActionResult FacebookLogin()
        {
            var properties = _signInManager
                .ConfigureExternalAuthenticationProperties("Facebook", Url.Action("ExternalLoginCallback", "login"));
            return Challenge(properties, "Facebook");

        }
        [HttpGet]
        [Route("fb-callback")]
        public async Task<IActionResult> ExternalLoginCallback()
        {
            ExternalLoginInfo info = await _signInManager.GetExternalLoginInfoAsync();
            string token = "";
            try
            {
                token = await _loginService.HandleFacebookLogin(info);
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }

            if (token != null)
            {
                return Ok(token);
            }
            else
            {
                return Ok("Une erreur est survenue lors du login");
            }
        }
        [HttpPost]
        [Route("ios-callback")]
        public async Task<IActionResult> IOSCallback([FromBody]FacebookLoginInfo facebook)
        {
            string token = "";
            try { 
            token = await _loginService.HandleIOSLogin(facebook);
            } catch(Exception e) {
                return BadRequest(e.Message);
            }

            if (token != null)
            {
                return Ok(token);
            }
            else
            {
                return Ok("Failed to receive token");
            }
        }
    }
}