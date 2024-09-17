-- CreateTable
CREATE TABLE `OperationRecord` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `cutType` VARCHAR(191) NOT NULL,
    `operationName` VARCHAR(191) NOT NULL,
    `calculatedTime` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
