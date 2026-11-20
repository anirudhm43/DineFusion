
import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import AppSidebar from "@/components/layout/app-sidebar";
import AppHeader from "@/components/layout/app-header";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "DineFusion | Restaurant Management",
  description:
    "Restaurant management dashboard for orders, menu, customers and analytics.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="min-h-screen bg-slate-50 font-sans text-slate-900">
        <div className="flex min-h-screen">
          <AppSidebar />

          <div className="min-w-0 flex-1">
            <AppHeader />

            <main className="mx-auto w-full max-w-[1600px] p-5 md:p-8">
              {children}
            </main>
          </div>
        </div>
      </body>
    </html>
  );
}
