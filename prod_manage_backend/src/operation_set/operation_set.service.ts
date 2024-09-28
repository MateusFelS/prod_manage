import { Injectable } from "@nestjs/common";
import { PrismaService } from "src/prisma/prisma.service";
import { OperationSet } from "@prisma/client";

@Injectable()
export class OperationSetService{
    constructor(private prisma: PrismaService){}

    async getAllOperationSets(): Promise<OperationSet[]>{
        return this.prisma.operationSet.findMany();
    }

    async getOperationSetById(id: number): Promise<OperationSet>{
        return this.prisma.operationSet.findUnique({
            where: {
                id
            }
        });
    }

    async createOperationSet(data: OperationSet): Promise<OperationSet> {
      return this.prisma.operationSet.create({
        data
      });
    }
    
    async updateOperationSet(id: number, data: OperationSet): Promise<OperationSet> {
      return this.prisma.operationSet.update({
        where: {
          id,
        },
       data
      });
    }
    

    async deleteOperationSet(id: number): Promise<OperationSet>{
        return this.prisma.operationSet.delete({
            where: {
                id
            }
        })
    }
}