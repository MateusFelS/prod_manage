import { Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService } from "src/prisma/prisma.service";
import { CutRecord } from "@prisma/client";

@Injectable()
export class CutRecordService {
  constructor(private prisma: PrismaService) {}

  async getAllCutRecords(): Promise<CutRecord[]> {
    return this.prisma.cutRecord.findMany();
  }

  async getCutRecordById(id: number): Promise<{ cutRecord: CutRecord; image: Buffer | null }> {
    const cutRecord = await this.prisma.cutRecord.findUnique({
      where: { id },
    });
  
    if (cutRecord?.image) {
      return { cutRecord, image: Buffer.from(cutRecord.image) };
    }
  
    return { cutRecord, image: null };
  }
  

  async createCutRecord(data: CutRecord): Promise<CutRecord> {
    return this.prisma.cutRecord.create({
      data: {
        ...data,
        limiteDate: new Date(data.limiteDate),
      },
    });
  }

  async updateCutRecord(id: number, data: CutRecord): Promise<CutRecord> {
    return this.prisma.cutRecord.update({
      where: { id },
      data: {
        ...data,
        limiteDate: new Date(data.limiteDate),
      },
    });
  }

  async deleteCutRecord(id: number): Promise<CutRecord> {
    return this.prisma.cutRecord.delete({
      where: { id },
    });
  }

  async updateCutRecordStatus(id: number, status: string): Promise<CutRecord> {
    return this.prisma.cutRecord.update({
      where: { id },
      data: { status },
    });
  }

  async uploadImageForCutRecord(cutRecordId: number, file: Express.Multer.File): Promise<{ message: string; imagePath: string }> {
    const imageBuffer = file.buffer;
  
    await this.prisma.cutRecord.update({
      where: { id: cutRecordId },
      data: {
        image: imageBuffer,
      },
    });
  
    return { message: 'Imagem enviada com sucesso', imagePath: '' };
  }
  
  async getCutRecordWithImage(id: number): Promise<{ cutRecord: CutRecord; imageBuffer: Buffer | null }> {
    const cutRecord = await this.prisma.cutRecord.findUnique({
      where: { id },
    });

    let imageBuffer: Buffer | null = null;
    if (cutRecord?.image) {
      imageBuffer = Buffer.from(cutRecord.image);
    }

    return { cutRecord, imageBuffer };
  }
}
