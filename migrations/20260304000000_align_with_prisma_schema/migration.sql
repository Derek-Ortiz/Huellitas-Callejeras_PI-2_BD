/*
  Warnings:

  - You are about to drop the column `usuario_id` foreign key on the `animales` table. The column remains but without foreign key constraint.
  - Added the required column `refugio_id` to the `roles` table without a default value. This is not possible if the table is not empty.

*/

-- AlterEnum
ALTER TYPE "movimiento_motivo" ADD VALUE 'extravio';

-- DropForeignKey
ALTER TABLE "animales" DROP CONSTRAINT "animales_usuario_id_fkey";

-- AlterTable
ALTER TABLE "roles" ADD COLUMN "refugio_id" UUID NOT NULL;

-- AddForeignKey
ALTER TABLE "roles" ADD CONSTRAINT "roles_refugio_id_fkey" FOREIGN KEY ("refugio_id") REFERENCES "refugios"("id_refugio") ON DELETE RESTRICT ON UPDATE CASCADE;
