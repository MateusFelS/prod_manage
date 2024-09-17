import { Module } from '@nestjs/common';
import { CutRecordService } from './cut_record.service';
import { CutRecordController } from './cut_record.controller';
import { PrismaService } from '../prisma/prisma.service'; // Assumindo que você tem um serviço Prisma configurado

@Module({
  controllers: [CutRecordController],
  providers: [CutRecordService, PrismaService],
})
export class CutRecordModule {}
