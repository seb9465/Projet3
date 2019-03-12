using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace PolyPaint
{
    public abstract class BaseMessage
    {
        [JsonIgnore]
        private readonly JsonSerializerSettings SerializerSettings = new JsonSerializerSettings
        {
            ContractResolver = new CamelCasePropertyNamesContractResolver(),
            NullValueHandling = NullValueHandling.Ignore
        };

        public override string ToString() => JsonConvert.SerializeObject(this, SerializerSettings);
    }
}
