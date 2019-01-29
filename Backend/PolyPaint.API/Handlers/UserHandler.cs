using System.Collections.Concurrent;

namespace PolyPaint.API.Handlers
{
    public static class UserHandler
    {
        // key: userId, value: groupId
        public readonly static ConcurrentDictionary<string, string> UserGroupMap = new ConcurrentDictionary<string, string>();
    }
}