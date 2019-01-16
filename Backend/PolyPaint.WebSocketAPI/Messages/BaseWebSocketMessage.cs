using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace PolyPaint.WebSocketAPI.Messages
{
    public class BaseWebSocketMessage : IWebSocketMessage
    {
        public MessageType Type { get; set; }
        public string Data { get; set; }
        public System.DateTime Timestamp { get; set; }

        [JsonIgnore]
        private readonly JsonSerializerSettings SerializerSettings = new JsonSerializerSettings
        {
            ContractResolver = new CamelCasePropertyNamesContractResolver(),
            NullValueHandling = NullValueHandling.Ignore
        };

        public BaseWebSocketMessage(MessageType type, string data)
        {
            Type = type;
            Data = data;
            Timestamp = System.DateTime.Now;
        }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this, SerializerSettings);
        }
    }
}
