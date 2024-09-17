import { Injectable } from "@nestjs/common";
import { PrismaService } from "src/prisma/prisma.service";
import { Employee } from "@prisma/client";

@Injectable()
export class EmployeeService{
    constructor(private prisma: PrismaService){}

    async getAllEmployees(): Promise<Employee[]>{
        return this.prisma.employee.findMany();
    }

    async getEmployeeById(id: number): Promise<Employee>{
        return this.prisma.employee.findUnique({
            where: {
                id
            }
        });
    }

    async createEmployee(data: Employee): Promise<Employee> {
      return this.prisma.employee.create({
        data: {
          ...data,
          entryDate: new Date(data.entryDate), 
        },
      });
    }
    
    async updateEmployee(id: number, data: Employee): Promise<Employee> {
      return this.prisma.employee.update({
        where: {
          id,
        },
        data: {
          ...data,
          entryDate: new Date(data.entryDate), 
        },
      });
    }
    

    async deleteEmployee(id: number): Promise<Employee>{
        return this.prisma.employee.delete({
            where: {
                id
            }
        })
    }
}