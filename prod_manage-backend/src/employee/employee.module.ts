import { Module } from '@nestjs/common';
import { EmployeeService } from './employee.service';
import { EmployeeController } from './employee.controller';
import { PrismaModule } from 'src/prisma/prisma.module';

@Module({
  providers: [EmployeeService],
  controllers: [EmployeeController],
  imports: [PrismaModule],
})
export class EmployeeModule {}
