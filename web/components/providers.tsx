'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { StarknetProvider } from '@/components/starknet-provider'
import { useState } from 'react'

export function Providers({ children }: { children: React.ReactNode }) {
    const [queryClient] = useState(() => new QueryClient())

    return (
        <StarknetProvider>
            <QueryClientProvider client={queryClient}>
                {children}
            </QueryClientProvider>
        </StarknetProvider>
    )
}
