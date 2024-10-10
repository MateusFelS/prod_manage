import { Injectable } from "@nestjs/common";
import { PrismaService } from "src/prisma/prisma.service";
import { Performance } from "@prisma/client";

@Injectable()
export class PerformanceService{
    constructor(private prisma: PrismaService){}

    async createPerformance(data: Performance): Promise<Performance> {
      return this.prisma.performance.create({
        data: {
          ...data,
          date: new Date(data.date), 
        },
      });
    }
    
    async getAllPerformances(): Promise<Performance[]>{
      return this.prisma.performance.findMany();
    }

    async getPerformanceById(id: number): Promise<Performance>{
      return this.prisma.performance.findUnique({
          where: {
              id
          }
      });
    }

    async getPerformanceByDate(employeeId: number, date: string): Promise<Performance[]> {
        return this.prisma.performance.findMany({
            where: {
                employeeId,
                date: new Date(date),
            },
        });
    }


    async updatePerformance(id: number, data: Partial<Performance>): Promise<Performance> {
      return this.prisma.performance.update({
        where: {
          id,
        },
        data: {
          ...data,
          date: new Date(data.date),
        },
      });
    }
    
}