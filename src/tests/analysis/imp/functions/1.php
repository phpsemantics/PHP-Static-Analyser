// Expected
// [z |-> -1]  (concrete)
// [z |-> NEG] (signs)

<?php
function f($x) {
    return(-1);
    return(1);
}

$z = f(0);
?>