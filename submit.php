
<?php
	$ip = $_SERVER["REMOTE_ADDR"];

	// Create a json file for the rate limit if it doesn't exist
	if (!file_exists("ratelimit.json")) {
		file_put_contents("ratelimit.json", "[]");
	}

	$ratelimit = json_decode(file_get_contents("ratelimit.json"), true);
	$time = time();

	// Rate limit: 1 note per minute per IP
	if (isset($ratelimit[$ip]) && $ratelimit[$ip] > $time) {
		echo "Rate Limited.";

		exit();
	}

	$ply = trim($_POST["ply"]);
	$map = trim($_POST["map"]);
	$pos = trim($_POST["pos"]);
	$text = trim($_POST["text"]);
	$explicit = isset($_POST["explicit"]) ? $_POST["explicit"] : null;


	if ($ply == "" || $map == "" || $pos == "" || $text == "") {
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

	// Read the json file
	$notes = json_decode(file_get_contents("stored/$map.json"), true);

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

	foreach ($notes as $note) {
		if ($note["explicit"] == "1") {
			// Convert the note's position string into a vector
			$notePos = parseVector($note["pos"]);

			// Check the squared distance; skip if it's 1000 or more
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
		"ply" => $ply,
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
	$ratelimit[$ip] = $time + 600;
	file_put_contents("ratelimit.json", json_encode($ratelimit));
?>
