import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Tickwing',
  description: '观鸟者社区平台',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh-CN">
      <body>{children}</body>
    </html>
  );
}
