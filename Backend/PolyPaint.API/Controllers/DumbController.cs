using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace PolyPaint.API.Controllers
{
    [Route("api/[controller]")]
    public class DumbController: ControllerBase
    {
        public DumbController()
        {
        }

        [HttpGet]
        public async Task<IActionResult> dumb()
        {
            return Ok("DUMB");
        }
    }
}
