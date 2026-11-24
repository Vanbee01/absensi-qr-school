import {PrismaClient} from "@prisma/client";import bcrypt from "bcryptjs";
const prisma=new PrismaClient();
async function main(){const email=process.env.BOOTSTRAP_ADMIN_EMAIL;const password=process.env.BOOTSTRAP_ADMIN_PASSWORD;const name=process.env.BOOTSTRAP_ADMIN_NAME||"Administrator";if(!email||!password)return;const count=await prisma.user.count({where:{role:"ADMIN"}});if(count>0){console.log("Administrator already exists; skipping seed.");return;}await prisma.user.create({data:{name,email:email.toLowerCase(),passwordHash:await bcrypt.hash(password,12),role:"ADMIN",active:true}});console.log("Initial administrator created.");}
main().catch(e=>{console.error(e);process.exit(1)}).finally(async()=>prisma.$disconnect());
