import { Module } from '@nestjs/common';
import { EmployeeModule } from './employee/employee.module';
import { PrismaService } from 'src/prisma/prisma.service';
import { CutRecordModule } from './cut_record/cut_record.module';
import { PerformanceModule } from './performance/performance.module';
import { UserModule } from './users/users.module';
import { RoleModule } from './roles/role.module';
import { OperationRecordModule } from './operation_record/operation_record.module';


@Module({
  imports: [EmployeeModule, RoleModule, CutRecordModule, OperationRecordModule, PerformanceModule, UserModule],
  providers: [PrismaService],
})
export class AppModule {}
