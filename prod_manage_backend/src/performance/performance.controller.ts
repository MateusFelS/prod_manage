import { Controller, Post, Body, Get, Param, Put } from "@nestjs/common";
import { PerformanceService } from "./performance.service";
import { Performance } from "@prisma/client";

@Controller('performance')
export class PerformanceController{
    constructor(private readonly performanceService: PerformanceService){}

    @Post()
    async createPerformance(@Body() data: Performance){
        return this.performanceService.createPerformance(data);
    }

    @Get()
    async getAllPerformances(){
        return this.performanceService.getAllPerformances();
    }

    @Get(':id')
    async getPerformanceById(@Param('id') id: string) {
        return this.performanceService.getPerformanceById(Number(id));
    }

    @Get('by-date/:employeeId')
    async getPerformanceByDate(
        @Param('employeeId') employeeId: string, 
        @Query('date') date: string
    ) {
        return this.performanceService.getPerformanceByDate(Number(employeeId), date);
    }

    @Put(':id')
    async updatePerformance(@Param('id') id: string, @Body() data: Performance){
        return this.performanceService.updatePerformance(Number(id), data);
    }
}
