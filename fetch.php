
<?php
	$response = [];

	// Add the stats to the response
	$stats = json_decode(file_get_contents("stats.json"), true);
	$response["stats"] = $stats;

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

	// Respond
	echo json_encode($response);
?>
