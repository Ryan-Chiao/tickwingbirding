import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  transpilePackages: ['@tickwing/shared-types'],
};

export default nextConfig;
