/*
  Warnings:

  - You are about to drop the column `operationSetId` on the `operationrecord` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE `operationrecord` DROP FOREIGN KEY `OperationRecord_operationSetId_fkey`;

-- AlterTable
ALTER TABLE `operationrecord` DROP COLUMN `operationSetId`;

-- CreateTable
CREATE TABLE `_OperationRecordToOperationSet` (
    `A` INTEGER NOT NULL,
    `B` INTEGER NOT NULL,

    UNIQUE INDEX `_OperationRecordToOperationSet_AB_unique`(`A`, `B`),
    INDEX `_OperationRecordToOperationSet_B_index`(`B`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `_OperationRecordToOperationSet` ADD CONSTRAINT `_OperationRecordToOperationSet_A_fkey` FOREIGN KEY (`A`) REFERENCES `OperationRecord`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `_OperationRecordToOperationSet` ADD CONSTRAINT `_OperationRecordToOperationSet_B_fkey` FOREIGN KEY (`B`) REFERENCES `OperationSet`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
