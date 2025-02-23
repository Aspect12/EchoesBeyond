
<?php
	$response = [];

	// Add the stats to the response
	$stats = json_decode(file_get_contents("stats.json"), true);
	$response["stats"] = $stats;

	// Get a map list with the number of notes in them
	$maps = array_diff(scandir("stored"), [".", ".."]);
	$mapList = [];

	foreach ($maps as $map) {
		$notes = json_decode(file_get_contents("stored/$map"), true);
		$map = substr($map, 0, -5);
		$mapList[$map] = is_array($notes) ? count($notes) : 0;
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
