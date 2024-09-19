-- DropForeignKey
ALTER TABLE `cutrecord` DROP FOREIGN KEY `CutRecord_employeeId_fkey`;

-- AlterTable
ALTER TABLE `cutrecord` MODIFY `employeeId` INTEGER NULL;

-- AddForeignKey
ALTER TABLE `CutRecord` ADD CONSTRAINT `CutRecord_employeeId_fkey` FOREIGN KEY (`employeeId`) REFERENCES `Employee`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;
