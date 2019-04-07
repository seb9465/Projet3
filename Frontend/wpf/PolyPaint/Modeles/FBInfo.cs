using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace PolyPaint.Modeles
{
    class FBInfo
    {
        public string Id { get; set; }
        public string First_Name { get; set; }
        public string Last_Name { get; set; }
        public string Email { get; set; }

        public FBInfo() { }
    }

    class PolyPaintFBInfo
    {
        public string Username { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Fbtoken { get; set; }

        [JsonIgnore]
        private readonly JsonSerializerSettings SerializerSettings = new JsonSerializerSettings
        {
            ContractResolver = new DefaultContractResolver(),
            NullValueHandling = NullValueHandling.Ignore
        };

        public override string ToString() => JsonConvert.SerializeObject(this, SerializerSettings);
    }
}
