import java.io.*;
import java.util.*;
import java.nio.*;
import org.json.JSONObject;

public class ProcessJSON {

	public static void main(String args[]) {
		try {
			Scanner scanner = new Scanner( new File("../data.json"), "UTF-8" );
			String data = scanner.next();
			scanner.close(); // Put this call in a finally block

			// String data = readFile("data.json", StandardCharsets.UTF_8);
			JSONObject jo = new JSONObject(data);
			System.out.print(jo.toString());
		} catch (Exception e) {
			System.err.println("exception: " + e);
			System.exit(1);
		}
	}
}