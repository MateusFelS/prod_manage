import { Controller, Post, Body, Get, Param, Delete } from "@nestjs/common";
import { RoleService } from "./role.service";
import { Role } from "@prisma/client";

@Controller('roles')
export class RoleController{
    constructor(private readonly roleService: RoleService){}

    @Post()
    async createRole(@Body() data: Role){
        return this.roleService.createRole(data);
    }

    @Get()
    async getAllRoles(){
        return this.roleService.getAllRoles();
    }

    @Get(':id')
    async getUsersById(@Param('id') id: string){
        return this.roleService.getRoleById(Number(id));
    }

    @Delete(':id')
    async deleteRole(@Param('id') id: string){
        return this.roleService.deleteRole(Number(id));
    }
}