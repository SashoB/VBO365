<?php
//MySQL Connection - change parameters
$conn = new mysqli("localhost", "-mysqlusername-", "-mysqlpassword-", "-dbname-");
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$GetReports = "SELECT * FROM `VBOReports` INNER JOIN VBOTenants ON VBOReports.TenantId = VBOTenants.TenantId WHERE `datetime`>'". date("Y-m")."-01"."'";
$result = mysqli_query($conn, $GetReports);
echo '<table border="1" align="center">';
echo '<tr><th>Datetime</th><th>TenantName</th><th>TenantId</th><th>UsedLicenses</th><th>TotalLicenses</th><th>ExpirationDate</th><th>LicenseType</th></tr>';
$SUM = 0;
while($Data = mysqli_fetch_assoc($result)) {
        echo '<tr><td>'.$Data['datetime'].'</td><td>'.$Data['TenantName'].'</td><td>'.$Data['TenantId'].'</td><td>'.$Data['UsedLicenses'].'</td><td>'.$Data['TotalLicenses'].'</td><td>'.$Data['ExpirationDa>
        $SUM += $Data['UsedLicenses'];
}
echo '<tr><td>&nbsp;</td><td>&nbsp;</td><td>SUM</td><td>'.$SUM.'</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>';
echo '</table>';
mysqli_close($conn);

?>
