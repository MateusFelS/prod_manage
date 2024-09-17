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

}