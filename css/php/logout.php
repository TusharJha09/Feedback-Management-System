@@ -0,0 +1,5 @@
<?php 
    session_start();
    session_destroy();
    header("Location: ../index.php");
?>
