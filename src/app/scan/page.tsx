import { getSession } from "@/lib/auth";
import { redirect } from "next/navigation";
import Scanner from "@/components/scanner";
export const dynamic = "force-dynamic";
export default async function ScanPage(){const user=await getSession();if(!user||!["ADMIN","TEACHER"].includes(user.role))redirect("/login");return <main className="min-h-screen p-5 md:p-10"><div className="mx-auto max-w-5xl"><a href="/" className="text-sm font-semibold text-indigo-600">← Dashboard</a><h1 className="mt-4 text-3xl font-bold">Pemindaian QR Code</h1><p className="mt-2 text-slate-500">Gunakan kamera, unggah gambar QR, atau masukkan kode secara manual.</p><div className="mt-8"><Scanner/></div></div></main>;}