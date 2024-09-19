import { Controller, Post, Body, Get, Param } from "@nestjs/common";
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
}