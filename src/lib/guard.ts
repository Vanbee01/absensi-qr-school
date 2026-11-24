import { getSession } from "@/lib/auth";
import { NextResponse } from "next/server";
export async function requireRoles(roles: Array<"ADMIN"|"TEACHER"|"STUDENT">) {
 const user=await getSession();
 if(!user) return {user:null,response:NextResponse.json({error:"Silakan login."},{status:401})};
 if(!roles.includes(user.role)) return {user:null,response:NextResponse.json({error:"Akses ditolak."},{status:403})};
 return {user,response:null};
}