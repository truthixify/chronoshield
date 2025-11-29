import Link from "next/link"
import { Shield } from "lucide-react"
import { Button } from "@/components/ui/button"

export function Header() {
    return (
        <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
            <div className="container flex h-16 items-center justify-between">
                <Link href="/" className="flex items-center gap-2 font-bold text-xl">
                    <Shield className="h-6 w-6 text-primary" />
                    <span>ChronoShield</span>
                </Link>

                <nav className="hidden md:flex items-center gap-6 text-sm font-medium">
                    <Link href="/markets" className="transition-colors hover:text-primary">
                        Explore Markets
                    </Link>
                    <Link href="/create" className="transition-colors hover:text-primary">
                        Create Market
                    </Link>
                    <Link href="/positions" className="transition-colors hover:text-primary">
                        My Positions
                    </Link>
                </nav>

                <div className="flex items-center gap-4">
                    <Button>Connect Wallet</Button>
                </div>
            </div>
        </header>
    )
}
