import { Module } from '@nestjs/common';
import { OperationSetService } from './operation_set.service';
import { OperationSetController } from './operation_set.controller';
import { PrismaModule } from 'src/prisma/prisma.module';

@Module({
  providers: [OperationSetService],
  controllers: [OperationSetController],
  imports: [PrismaModule],
})

export class OperationSetModule {}
