/*
  Warnings:

  - You are about to drop the column `operationSetId` on the `cutrecord` table. All the data in the column will be lost.
  - You are about to drop the `_operationrecordtooperationset` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `operationRecords` to the `OperationSet` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE `_operationrecordtooperationset` DROP FOREIGN KEY `_OperationRecordToOperationSet_A_fkey`;

-- DropForeignKey
ALTER TABLE `_operationrecordtooperationset` DROP FOREIGN KEY `_OperationRecordToOperationSet_B_fkey`;

-- DropForeignKey
ALTER TABLE `cutrecord` DROP FOREIGN KEY `CutRecord_operationSetId_fkey`;

-- AlterTable
ALTER TABLE `cutrecord` DROP COLUMN `operationSetId`,
    ADD COLUMN `selectedOperations` JSON NULL;

-- AlterTable
ALTER TABLE `operationset` ADD COLUMN `operationRecords` JSON NOT NULL;

-- DropTable
DROP TABLE `_operationrecordtooperationset`;
