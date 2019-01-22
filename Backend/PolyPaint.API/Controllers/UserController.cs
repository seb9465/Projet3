using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PolyPaint.Core;
using PolyPaint.DataAccess.Services;
using PolyPaint.Core.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using PolyPaint.Core.DbModels;

namespace PolyPaint.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly UserService _userService;
        public UserController(UserService userService)
        {
            _userService = userService;
        }

        [Authorize]
        [HttpPost]
        public async Task<IActionResult> SaveNewCanvasAsync([FromBody]Canvas canvas)
        {
            ClaimsPrincipal user = this.User;
            string userId = user.FindFirstValue(ClaimTypes.NameIdentifier);

            await _userService.Save(userId, canvas);
            return Ok();
        }
    }
}