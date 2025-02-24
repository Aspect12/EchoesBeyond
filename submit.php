
<?php
	$ip = $_SERVER["REMOTE_ADDR"];

	// Create a json file for the rate limit if it doesn't exist
	if (!file_exists("ratelimit.json")) {
		file_put_contents("ratelimit.json", "[]");
	}

	$ratelimitFile = json_decode(file_get_contents("ratelimit.json"), true);
	$time = time();

	if (!file_exists("mapratelimit.json")) {
		file_put_contents("mapratelimit.json", "[]");
	}

	$map = trim($_POST["map"]);

	if (!file_exists("stored/$map.json")) {
		$mapratelimitFile = json_decode(file_get_contents("mapratelimit.json"), true);
		$mapratelimit = isset($mapratelimitFile[$ip]) ? $mapratelimitFile[$ip] : 0;

		if ($mapratelimit > $time) {
			echo "Rate Limited.";

			exit();
		}

		// 6 hours
		$mapratelimit = $time + 21600;
		$mapratelimitFile[$ip] = $mapratelimit;

		file_put_contents("mapratelimit.json", json_encode($mapratelimitFile));
		file_put_contents("stored/$map.json", "[]");
	}

	// Read the json file
	$notes = json_decode(file_get_contents("stored/$map.json"), true);

	// Rate limit: 1 note per 30 seconds per IP multiplied by the number of notes
	$noteCount = count($notes);
	$rateLimit = isset($ratelimitFile[$ip]) ? $ratelimitFile[$ip] : 0;
	$cooldown = $rateLimit + (30 * $noteCount);

	if ($cooldown > $time) {
		echo "Rate Limited.";

		exit();
	}

	$pos = trim($_POST["pos"]);
	$text = trim($_POST["text"]);
	$explicit = isset($_POST["explicit"]) ? $_POST["explicit"] : "0";

	if ($map == "" || $pos == "" || $text == "") {
		echo "Invalid input";

		exit();
	}

	// Create a json file for stats if it doesn't exist
	if (!file_exists("stats.json")) {
		file_put_contents("stats.json", "[]");
	}

	$stats = json_decode(file_get_contents("stats.json"), true);
	$stats["notes"] = $stats["notes"] ?? 0;
	$stats["maps"] = $stats["maps"] ?? 0;

	// Create a json file by the map name if it doesn't exist
	if (!file_exists("stored/$map.json")) {
		file_put_contents("stored/$map.json", "[]");

		$stats["maps"]++;
	}

	// Convert a comma-separated string to a vector (an array of numbers)
	function parseVector($str) {
		return array_map("floatval", explode(",", $str));
	}

	// Calculate the squared distance between two vectors
	function distToSqr($vec1, $vec2) {
		return pow($vec1[0] - $vec2[0], 2) +
			pow($vec1[1] - $vec2[1], 2) +
			pow($vec1[2] - $vec2[2], 2);
	}

	// Convert the client's position string into a vector
	$clientPos = parseVector($pos);

	if ($explicit == "0") {
		foreach ($notes as $note) {
			// Convert the note's position string into a vector
			$notePos = parseVector($note["pos"]);

			// Check the squared distance; exit if under 1000
			if (distToSqr($clientPos, $notePos) < 1000) {
				exit();
			}
		}
	}

	$id = time();

	// Remove newlines from text
	$text = str_replace("\n", " ", $text);

	// Limit text length to 512 characters
	$text = substr($text, 0, 512);

	// Add the new note
	$notes[] = array(
		"id" => $id,
		"pos" => $pos,
		"text" => $text,
		"explicit" => $explicit,
	);

	// Save the map file
	file_put_contents("stored/$map.json", json_encode($notes));

	// Save the stats file
	$stats["notes"]++;
	file_put_contents("stats.json", json_encode($stats));

	// Save the rate limit file
	$ratelimitFile[$ip] = $time;
	file_put_contents("ratelimit.json", json_encode($ratelimitFile));

	// Return the note ID
	echo $id;
?>
