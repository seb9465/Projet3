using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PolyPaint.Core;
using PolyPaint.DataAccess.Services;
using PolyPaint.Core.Models;
using System.Threading.Tasks;

namespace PolyPaint.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RegisterController : ControllerBase
    {
        private readonly RegisterService _registerService;
        public RegisterController(RegisterService registerService)
        {
            _registerService = registerService;
        }

        [HttpPost]
        public async Task<IActionResult> RegisterAsync(RegistrationViewModel registrationViewModel)
        {
            ApplicationUser user = new ApplicationUser(registrationViewModel);
            IdentityResult registrationStatus = await _registerService.RegisterNewUserAsync(user, registrationViewModel.Password);

            if (registrationStatus.Succeeded)
            {
                return Ok("Votre compte a été créer avec succès! Vous pouvez maintenant vous connecter.");
            }
            else
            {
                return BadRequest(registrationStatus.Errors);
            }
        }
    }
}