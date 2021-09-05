//MySQL Connection - change parameters
$conn = new mysqli("localhost", "-mysqlusername-", "-mysqlpassword-", "-dbname-");
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$GetTenants = "SELECT * FROM `VBOTenants` WHERE `Active`='1'";
$result = mysqli_query($conn, $GetTenants);
while($Data = mysqli_fetch_assoc($result)) {
        $insert = "INSERT INTO `VBO365`.`VBOReports`(`datetime`, `TenantId`) VALUES (NOW(), '".$Data['TenantId']."')";
        if (mysqli_query($conn, $insert)) {
                echo "Tenant monthly created successfully";
        } else {
                echo "Report not created: " . mysqli_error($conn);
        }
}
mysqli_close($conn);
