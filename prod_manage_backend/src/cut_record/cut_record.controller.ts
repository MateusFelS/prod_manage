import { Controller, Get, Post, Body, Param, Delete, Patch, Put, UseInterceptors, Res } from "@nestjs/common";
import { CutRecordService } from "./cut_record.service";
import { CutRecord } from "@prisma/client";
import { FileInterceptor } from '@nestjs/platform-express';
import { UploadedFile } from '@nestjs/common';
import { Response } from 'express';

@Controller('cut-records')
export class CutRecordController {
  constructor(private readonly cutRecordService: CutRecordService) {}

  @Get()
  async getAllCutRecords() {
    return this.cutRecordService.getAllCutRecords();
  }

  @Post()
  async createCutRecord(@Body() data: CutRecord) {
    return this.cutRecordService.createCutRecord(data);
  }

  @Get(':id')
  async getCutRecordsById(@Param('id') id: string) {
    return this.cutRecordService.getCutRecordById(Number(id));
  }

  @Put(':id')
  async updateCutRecord(@Param('id') id: string, @Body() data: CutRecord) {
    return this.cutRecordService.updateCutRecord(Number(id), data);
  }

  @Delete(':id')
  async deleteCutRecord(@Param('id') id: string) {
    return this.cutRecordService.deleteCutRecord(Number(id));
  }

  @Patch(':id')
  async updateStatus(@Param('id') id: string, @Body() data: { status: string }) {
    return this.cutRecordService.updateCutRecordStatus(Number(id), data.status);
  }

  @Post(':id/upload-image')
  @UseInterceptors(FileInterceptor('image'))
  async uploadImageForCutRecord(
    @Param('id') cutRecordId: string,
    @UploadedFile() image: Express.Multer.File,
  ): Promise<{ message: string; imagePath: string }> {
    return this.cutRecordService.uploadImageForCutRecord(parseInt(cutRecordId), image);
  }

  @Get(':id/get-image')
  async getImage(@Param('id') id: string, @Res() res: Response) {
    const { cutRecord, imageBuffer } = await this.cutRecordService.getCutRecordWithImage(parseInt(id));
    
    if (!cutRecord || !imageBuffer) {
      return res.status(404).send('Imagem não encontrada');
    }

    res.type('image/jpeg');
    res.send(imageBuffer);
  }
}
