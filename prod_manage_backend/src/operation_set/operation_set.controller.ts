import { Controller, Get, Post, Body, Param, Delete, Put } from "@nestjs/common";
import { OperationSetService } from "./operation_set.service";
import { OperationSet } from "@prisma/client";

@Controller('operation-set')
export class OperationSetController{
    constructor(private readonly operationSet: OperationSetService){}

    @Get()
    async getAllOperationSets(){
        return this.operationSet.getAllOperationSets();
    }

    @Post()
    async createOperationSet(@Body() data: OperationSet){
        return this.operationSet.createOperationSet(data);
    }

    @Get(':id')
    async getOperationSetById(@Param('id') id: string){
        return this.operationSet.getOperationSetById(Number(id));
    }
    
    @Put(':id')
    async updateOperationSet(@Param('id') id: string, @Body() data: OperationSet){
        return this.operationSet.updateOperationSet(Number(id), data);
    }

    @Delete(':id')
    async deleteOperationSet(@Param('id') id: string){
        return this.operationSet.deleteOperationSet(Number(id));
    }
}