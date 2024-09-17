import { Controller, Get, Post, Body, Param, Delete, Put } from "@nestjs/common";
import { ReportService } from "./report.service";
import { Report } from "@prisma/client";

@Controller('Reports')
export class ReportController{
    constructor(private readonly reportService: ReportService){}

    @Get()
    async getAllReports(){
        return this.reportService.getAllReports();
    }

    @Post()
    async createReport(@Body() data: Report){
        return this.reportService.createReport(data);
    }

    @Get(':id')
    async getReportsById(@Param('id') id: string){
        return this.reportService.getReportById(Number(id));
    }
    
    @Put(':id')
    async updateReport(@Param('id') id: string, @Body() data: Report){
        return this.reportService.updateReport(Number(id), data);
    }

    @Delete(':id')
    async deleteReport(@Param('id') id: string){
        return this.reportService.deleteReport(Number(id));
    }
}