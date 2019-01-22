namespace PolyPaint.DataStructures
{
    public class ConnectionInfo
    {
        public string Username { get; set; }
        public string GroupId { get; set; }

        public ConnectionInfo(string username, string groupId)
        {
            Username = username;
            GroupId = groupId;
        }
    }
}