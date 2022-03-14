using System;
using System.Text;
using Newtonsoft.Json.Linq;

public class MainTest {
	public static void Main(string[] args) {
		string data = System.IO.File.ReadAllText(@"data.json", System.Text.Encoding.UTF8);
		JObject o = JObject.Parse(data);
		// Console.WriteLine("o:" + o.ToString(Newtonsoft.Json.Formatting.None));
		System.IO.File.WriteAllText(@"data.json", o.ToString(Newtonsoft.Json.Formatting.None));
	}
}

