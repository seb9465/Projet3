using Microsoft.AspNetCore.Identity;
using PolyPaint.Core.ViewModels;

namespace PolyPaint.Core
{
    public class ApplicationUser : IdentityUser
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string FullName() => $"{FirstName} {LastName}";
        public ApplicationUser() : base()
        {
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
