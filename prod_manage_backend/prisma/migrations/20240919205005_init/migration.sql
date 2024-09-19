-- DropForeignKey
ALTER TABLE `performance` DROP FOREIGN KEY `Performance_employeeId_fkey`;

-- AddForeignKey
ALTER TABLE `Performance` ADD CONSTRAINT `Performance_employeeId_fkey` FOREIGN KEY (`employeeId`) REFERENCES `Employee`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
