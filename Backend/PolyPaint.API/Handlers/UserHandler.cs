using System.Collections.Concurrent;
using System.Collections.Generic;
using PolyPaint.Core;

namespace PolyPaint.API.Handlers
{
    public static class UserHandler
    {
        // key: groupId, value: Liste de userId
        public readonly static ConcurrentDictionary<string, List<string>> UserGroupMap
            = new ConcurrentDictionary<string, List<string>>();

        // key: ConnectionId, value: Group
        public readonly static ConcurrentDictionary<string, string> UserConnections
            = new ConcurrentDictionary<string, string>();

        public static void AddOrUpdateConnectionMap(string connectionId, string groupId)
        {
            UserConnections.AddOrUpdate(connectionId, groupId, (k, v) => { return groupId; });
        }

        public static void AddOrUpdateMap(string group, string id)
        {
            UserGroupMap.AddOrUpdate(group, new List<string>() { id }, (k, v) =>
            {
                v.Add(id);
                return v;
            });
        }

        public static bool TryGetByValue(ApplicationUser user, out string channelId)
        {
            channelId = null;
            foreach (var pair in UserGroupMap)
            {
                if (pair.Value.Contains(user.Id))
                {
                    channelId = pair.Key;
                    return true;
                }
            }

            return false;
        }
    }
}