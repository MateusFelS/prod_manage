import { Module } from '@nestjs/common';
import { OperationRecordService } from './operation_record.service';
import { OperationRecordController } from './operation_record.controller';
import { PrismaService } from '../prisma/prisma.service';

@Module({
  controllers: [OperationRecordController],
  providers: [OperationRecordService, PrismaService],
})
export class OperationRecordModule {}
