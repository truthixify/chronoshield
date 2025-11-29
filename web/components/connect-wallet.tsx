'use client'

import { useAccount, useConnect, useDisconnect } from "@starknet-react/core"
import { Button } from "@/components/ui/button"
import { useState } from "react"

export function ConnectWallet() {
    const { address } = useAccount()
    const { connect, connectors } = useConnect()
    const { disconnect } = useDisconnect()
    const [showConnectors, setShowConnectors] = useState(false)

    if (address) {
        return (
            <Button variant="outline" onClick={() => disconnect()}>
                {address.slice(0, 6)}...{address.slice(-4)}
            </Button>
        )
    }

    return (
        <div className="relative">
            <Button onClick={() => setShowConnectors(!showConnectors)}>
                Connect Wallet
            </Button>
            {showConnectors && (
                <div className="absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-background border ring-1 ring-black ring-opacity-5 z-50">
                    <div className="py-1" role="menu">
                        {connectors.map((connector) => (
                            <button
                                key={connector.id}
                                onClick={() => {
                                    connect({ connector })
                                    setShowConnectors(false)
                                }}
                                className="block w-full text-left px-4 py-2 text-sm hover:bg-accent"
                                role="menuitem"
                            >
                                Connect {connector.name}
                            </button>
                        ))}
                    </div>
                </div>
            )}
        </div>
    )
}

