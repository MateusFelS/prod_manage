import { Injectable } from "@nestjs/common";
import { PrismaService } from "src/prisma/prisma.service";
import { Role } from "@prisma/client";

@Injectable()
export class RoleService{
    constructor(private prisma: PrismaService){}

    async createRole(data: Role): Promise<Role> {
      return this.prisma.role.create({
        data
      });
    }
    
    async getAllRoles(): Promise<Role[]>{
      return this.prisma.role.findMany();
    }

    async getRoleById(id: number): Promise<Role>{
      return this.prisma.role.findUnique({
          where: {
              id
          }
      });
  }
}