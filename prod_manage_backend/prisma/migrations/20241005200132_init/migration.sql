/*
  Warnings:

  - Added the required column `calculatedTime` to the `OperationRecord` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE `operationrecord` ADD COLUMN `calculatedTime` VARCHAR(191) NOT NULL;
