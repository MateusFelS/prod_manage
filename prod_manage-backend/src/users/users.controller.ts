import { Controller, Get, Post, Body, Param, Delete, Put } from "@nestjs/common";
import { UserService } from "./users.service";
import { User } from "@prisma/client";

@Controller('users')
export class UserController{
    constructor(private readonly userService: UserService){}

    @Get()
    async getAllUsers(){
        return this.userService.getAllUsers();
    }

    @Post()
    async createUser(@Body() data: User){
        return this.userService.createUser(data);
    }

    @Get(':id')
    async getUsersById(@Param('id') id: string){
        return this.userService.getUserById(Number(id));
    }
    
    @Put(':id')
    async updateUser(@Param('id') id: string, @Body() data: User){
        return this.userService.updateUser(Number(id), data);
    }

    @Delete(':id')
    async deleteUser(@Param('id') id: string){
        return this.userService.deleteUser(Number(id));
    }
}