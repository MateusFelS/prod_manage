import { Injectable } from "@nestjs/common";
import { PrismaService } from "src/prisma/prisma.service";
import { Report } from "@prisma/client";

@Injectable()
export class ReportService{
    constructor(private prisma: PrismaService){}

    async getAllReports(): Promise<Report[]>{
        return this.prisma.report.findMany();
    }

    async getReportById(id: number): Promise<Report>{
        return this.prisma.report.findUnique({
            where: {
                id
            }
        });
    }

    async createReport(data: Report): Promise<Report> {
      return this.prisma.report.create({
        data
      });
    }
    
    async updateReport(id: number, data: Report): Promise<Report> {
      return this.prisma.report.update({
        where: {
          id,
        },
        data
      });
    }
    

    async deleteReport(id: number): Promise<Report>{
        return this.prisma.report.delete({
            where: {
                id
            }
        })
    }
}