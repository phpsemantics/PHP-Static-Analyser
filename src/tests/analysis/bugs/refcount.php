<?php
// This causes issues with refcounting
$x = 123;
function &foo() {
	global $x;
	$y = 1;
	if (2 == 4)  {
		return $x;
	} 
	else {
		return $y;
	}
}
$result = &foo();
?>
