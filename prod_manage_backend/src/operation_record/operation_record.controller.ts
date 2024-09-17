import { Controller, Post, Body, Get, Param } from "@nestjs/common";
import { OperationRecordService } from "./operation_record.service";
import { OperationRecord } from "@prisma/client";

@Controller('operations')
export class OperationRecordController{
    constructor(private readonly operationService: OperationRecordService){}

    @Post()
    async createOperation(@Body() data: OperationRecord){
        return this.operationService.createOperationRecord(data);
    }

    @Get()
    async getAllOperations(){
        return this.operationService.getAllOperationRecords();
    }

    @Get(':id')
    async getUsersById(@Param('id') id: string){
        return this.operationService.getOperationRecordsById(Number(id));
    }
}