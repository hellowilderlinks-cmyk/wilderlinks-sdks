using System;
using System.Collections.Generic;

namespace Wilderbots.Wilderlinks
{
    [Serializable]
    public sealed class WilderlinksConfig
    {
        public string BaseUrl;
        public List<string> Domains = new List<string>();
        public string ApiKey;

        public WilderlinksConfig(string baseUrl, IEnumerable<string> domains, string apiKey = null)
        {
            BaseUrl = baseUrl;
            Domains = domains == null ? new List<string>() : new List<string>(domains);
            ApiKey = apiKey;
        }
    }
}
