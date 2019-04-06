using System;
namespace PolyPaint.Core.ViewModels
{
    public class FacebookLoginInfo
    {
        public string FbToken { get; set; }
        public string FirstName { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public FacebookLoginInfo(string FbToken, string FirstName, string Username, string email)
        {
            this.Email = email;
            this.FbToken = FbToken;
            this.FirstName = FirstName;
            this.Username = Username;
        }
        public FacebookLoginInfo()
        {
        }
    }
}
