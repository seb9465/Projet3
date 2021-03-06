﻿using Microsoft.AspNetCore.Mvc;
using PolyPaint.DataAccess.Services;
using System.Collections.Generic;
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
        private readonly CanvasService _canvasService;
        public UserController(UserService userService, CanvasService canvasService)
        {
            _userService = userService;
            _canvasService = canvasService;
        }

        [Authorize]
        [HttpPost]
        [Route("Canvas")]
        public async Task<IActionResult> SaveNewCanvasAsync([FromBody]Canvas canvas)
        {
            ClaimsPrincipal user = this.User;
            string userId = user.FindFirstValue(ClaimTypes.NameIdentifier);

            await _userService.Save(userId, canvas);
            return Ok();
        }

        [Authorize]
        [HttpGet]
        [Route("Canvas")]
        public async Task<IActionResult> GetAllCanvasFromUser()
        {
            ClaimsPrincipal user = this.User;
            string userId = user.FindFirstValue(ClaimTypes.NameIdentifier);
            List<Canvas> canvas = await _userService.GetAllCanvas(userId);
            return Ok(canvas);
        }

        [HttpGet]
        [Route("Canvas/{id}")]
        public async Task<IActionResult> GetCanvasById(string id)
        {
            Canvas canvas = _canvasService.GetCanvasById(id);
            return Ok(canvas);
        }

        [HttpGet]
        [Authorize]
        [Route("tutorial")]
        public async Task<IActionResult> GetTutorialValue()
        {
            ClaimsPrincipal user = this.User;
            string userId = user.FindFirstValue(ClaimTypes.NameIdentifier);
            bool wasTheTutorialShowed = await _userService.GetTutorialValue(userId);
            return Ok(wasTheTutorialShowed);
        }


        [HttpGet]
        [Authorize]
        [Route("tutorial/{wasSeen}")]
        public async Task<IActionResult> GetTutorialValue(bool wasSeen)
        {
            ClaimsPrincipal user = this.User;
            string userId = user.FindFirstValue(ClaimTypes.NameIdentifier);
            bool wasCompletedOnSenCriss = await _userService.SetTutorialValue(userId, wasSeen);
            return Ok(wasCompletedOnSenCriss);
        }


        [Authorize]
        [HttpGet]
        [Route("AllCanvas")]
        public async Task<IActionResult> GetAllCanvas()
        {
            List<Canvas> canvas = _canvasService.GetAllCanvas();
            return Ok(canvas);
        }

        [Authorize]
        [HttpGet]
        [Route("logout")]
        public async Task<IActionResult> LogoutUser()
        {
            ClaimsPrincipal user = this.User;
            string userId = user.FindFirstValue(ClaimTypes.NameIdentifier);
            bool success = await _userService.LogoutUser(userId);
            if (success)
            {
                return Ok("Déconnexion réussi");

            }
            return BadRequest("Erreur lors de la déconnexion");
        }
    }
}