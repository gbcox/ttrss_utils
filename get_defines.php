<?php
	// Obtain variables defined in config.php
	// and pass back to ckvar_ttrss.sh
	
	require_once "$argv[1]config.php";
	$const = get_defined_constants(true);
	
	foreach($const['user'] as $k => $v) {
		echo "export $k='$v';";
}?>
