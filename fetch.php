
<?php
	$response = [];

	// Add the stats to the response
	$stats = json_decode(file_get_contents("stats.json"), true);
	$response["stats"] = $stats;

	// Get all .json files in the stored folder and add their name to the response without the json extension
	$mapList = [];

	$files = glob("stored/*.json");

	foreach ($files as $file) {
		$mapList[] = pathinfo($file, PATHINFO_FILENAME);
	}

	$response["mapList"] = $mapList;

	$map = isset($_GET["map"]) ? $_GET["map"] : "";
	if ($map == "") {
		// Return the stats and nothing else
		echo json_encode($response);

		exit();
	}

	// Read the json file by the map name
	$notes = [];

	if (file_exists("stored/$map.json")) {
		$notes = json_decode(file_get_contents("stored/$map.json"), true);
	}

	$response["notes"] = $notes;

	$ip = $_SERVER["REMOTE_ADDR"];
	$ratelimit = [];

	if (file_exists("ratelimit.json")) {
		$ratelimit = json_decode(file_get_contents("ratelimit.json"), true);
	}

	$response["ratelimit"] = $ratelimit[$ip] ?? 0;

	// Respond
	echo json_encode($response);
?>
