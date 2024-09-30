import { Injectable } from "@nestjs/common";
import { PrismaService } from "src/prisma/prisma.service";
import { OperationRecord } from "@prisma/client";

@Injectable()
export class OperationRecordService{
    constructor(private prisma: PrismaService){}

    async createOperationRecord(data: OperationRecord): Promise<OperationRecord> {
      return this.prisma.operationRecord.create({
        data
      });
    }
    
    async getAllOperationRecords(): Promise<OperationRecord[]>{
      return this.prisma.operationRecord.findMany();
    }

    async getOperationRecordsById(id: number): Promise<OperationRecord>{
      return this.prisma.operationRecord.findUnique({
          where: {
              id
          }
      });
  }

  async deleteOperationRecord(id: number): Promise<OperationRecord> {
    return this.prisma.operationRecord.delete({
      where: { id },
    });
  }
}