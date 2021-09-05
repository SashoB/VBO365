CREATE TABLE `VBOTenants` (
`id` int(11) NOT NULL AUTO_INCREMENT,
`TenantName` varchar(128) CHARACTER SET utf8 COLLATE utf8_slovenian_ci NOT NULL,
`TenantId` varchar(32) CHARACTER SET utf8 COLLATE utf8_slovenian_ci NOT NULL,
`DateAdded` datetime NULL,
PRIMARY KEY (`id`, `TenantName`, `TenantId`) ,
UNIQUE INDEX `TenantName` (`TenantName` ASC),
UNIQUE INDEX `TenantId` (`TenantId` ASC)
);
CREATE TABLE `VBOReports` (
`id` int(11) NOT NULL AUTO_INCREMENT,
`datetime` datetime NULL,
`TenantId` varchar(32) CHARACTER SET utf8 COLLATE utf8_slovenian_ci NULL,
`UsedLicenses` int NULL DEFAULT NULL,
`TotalLicenses` int NULL,
`ExpirationDate` date NULL,
`LicenseType` varchar(16) CHARACTER SET utf8 COLLATE utf8_slovenian_ci NULL,
PRIMARY KEY (`id`) 
);

ALTER TABLE `VBOReports` ADD CONSTRAINT `fk_VBOReports_VBOTenants_1` FOREIGN KEY (`TenantId`) REFERENCES `VBOTenants` (`TenantId`);

