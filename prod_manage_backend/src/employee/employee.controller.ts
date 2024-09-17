import { Controller, Get, Post, Body, Param, Delete, Put } from "@nestjs/common";
import { EmployeeService } from "./employee.service";
import { Employee } from "@prisma/client";

@Controller('employees')
export class EmployeeController{
    constructor(private readonly employeeService: EmployeeService){}

    @Get()
    async getAllEmployees(){
        return this.employeeService.getAllEmployees();
    }

    @Post()
    async createEmployee(@Body() data: Employee){
        return this.employeeService.createEmployee(data);
    }

    @Get(':id')
    async getEmployeesById(@Param('id') id: string){
        return this.employeeService.getEmployeeById(Number(id));
    }
    
    @Put(':id')
    async updateEmployee(@Param('id') id: string, @Body() data: Employee){
        return this.employeeService.updateEmployee(Number(id), data);
    }

    @Delete(':id')
    async deleteEmployee(@Param('id') id: string){
        return this.employeeService.deleteEmployee(Number(id));
    }
}