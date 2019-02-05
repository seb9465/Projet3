using System.Collections.Generic;
using Microsoft.AspNetCore.Identity;
using PolyPaint.Core.DbModels;
using PolyPaint.Core.ViewModels;

namespace PolyPaint.Core
{
    public class ApplicationUser : IdentityUser
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public List<Canvas> Canvas { get; set; }
        public string FullName() => $"{FirstName} {LastName}";
        public bool IsLoggedIn { get; set; } = false;
        public ApplicationUser() : base()
        {
            Canvas = new List<Canvas>();
        }
        public ApplicationUser(RegistrationViewModel user)
        {
            FirstName = user.FirstName;
            LastName = user.LastName;
            Email = user.Email;
            UserName = user.Username;
        }
    }
}
