<?php
if(!isset($_POST)) { exit; }
$DATA = $_POST;

//MySQL Connection - change parameters
$conn = new mysqli("localhost", "-mysqlusername-", "-mysqlpassword-", "-dbname-");
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

//GET VARIABLES
$TenantName = mysqli_real_escape_string($conn, trim(addslashes($DATA['TenantName'])));
$TenantId = mysqli_real_escape_string($conn, trim(addslashes($DATA['TenantId'])));
$UsedLicenses = mysqli_real_escape_string($conn, trim(addslashes($DATA['UsedLicenses'])));
$TotalLicenses = mysqli_real_escape_string($conn, trim(addslashes($DATA['TotalLicenses'])));
$ExpirationDate = mysqli_real_escape_string($conn, trim(addslashes($DATA['ExpirationDate'])));
$LicenseType = mysqli_real_escape_string($conn, trim(addslashes($DATA['LicenseType'])));

$GetId = "SELECT * FROM `VBOReports` WHERE `TenantId`='$TenantId' ORDER BY `id` DESC LIMIT 1";
$result = mysqli_query($conn, $GetId);
$Data = mysqli_fetch_assoc($result);
if(strtotime($Data['datetime']) < time()-172800){ //if record is older than two days or does not exists
        echo "Error: No report to fill";
} else {
        $update = "UPDATE `VBOReports` SET `UsedLicenses`='$UsedLicenses', `TotalLicenses`='$TotalLicenses', `ExpirationDate`='$ExpirationDate', `LicenseType`='$LicenseType' WHERE `id`='".$Data['id']."'";
        if (mysqli_query($conn, $update)) {
                echo "Report inserted successfully";
        } else {
                echo "Report not inserted: " . mysqli_error($conn);
        }
}
mysqli_close($conn);
?>
