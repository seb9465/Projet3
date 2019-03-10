using System.Collections.Concurrent;
using System.Collections.Generic;

namespace PolyPaint.API.Handlers
{
    public static class UserHandler
    {
        // key: groupId, value: Liste de userId
        public readonly static ConcurrentDictionary<string, List<string>> UserGroupMap
            = new ConcurrentDictionary<string, List<string>>();

        public static void AddOrUpdateMap(string group, string id)
        {
            UserGroupMap.AddOrUpdate(group, new List<string>() { id }, (k, v) =>
            {
                v.Add(id);
                return v;
            });
        }
    }
}