
<?php
	$ply = trim($_POST['ply']);
	$map = trim($_POST['map']);
	$pos = trim($_POST['pos']);
	$text = trim($_POST['text']);

	if ($ply == "" || $map == "" || $pos == "" || $text == "") {
		echo "Invalid input";

		exit();
	}

	// Create a json file for stats if it doesn't exist
	if (!file_exists("stats.json")) {
		file_put_contents("stats.json", "[]");
	}

	$stats = json_decode(file_get_contents("stats.json"), true);
	$stats['notes'] = $stats['notes'] ?? 0;
	$stats['maps'] = $stats['maps'] ?? 0;

	// Create a json file by the map name if it doesn't exist
	if (!file_exists("stored/$map.json")) {
		file_put_contents("stored/$map.json", "[]");

		$stats['maps']++;
	}

	// Read the json file
	$notes = json_decode(file_get_contents("stored/$map.json"), true);

	// Prevent creating notes too close to other notes
/* 	foreach ($notes as $note) {
		if (abs($note['pos'] - $pos) < 10) {
			echo "Too close to another note";

			exit();
		}
	} */

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
		"text" => $text
	);

	// Write the json file
	file_put_contents("stored/$map.json", json_encode($notes));

	$stats['notes']++;

	file_put_contents("stats.json", json_encode($stats));
?>
