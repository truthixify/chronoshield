import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { ArrowRight, Shield, Lock, Trophy, TrendingUp } from "lucide-react"

export default function Home() {
  return (
    <div className="flex flex-col gap-12 pb-20">
      {/* Hero Section */}
      <section className="relative py-20 md:py-32">
        <div className="container relative z-10 flex flex-col items-center text-center gap-6 mx-auto px-4">
          <div className="inline-flex items-center rounded-lg border px-3 py-1 text-sm text-muted-foreground">
            <Shield className="mr-2 h-4 w-4" />
            <span>Privacy-First Prediction Market</span>
          </div>
          <h1 className="text-4xl md:text-6xl font-bold tracking-tight lg:text-7xl">
            Bet Privately. <br />
            Win Fairly.
          </h1>
          <p className="max-w-[42rem] leading-normal text-muted-foreground sm:text-xl sm:leading-8">
            Your positions stay hidden until markets resolve.
            Experience the first zero-knowledge prediction market where strategy meets privacy.
          </p>
          <div className="flex gap-4 mt-4">
            <Button size="lg" asChild className="h-12 px-8 text-base">
              <Link href="/markets">
                Explore Markets <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
            <Button size="lg" variant="outline" asChild className="h-12 px-8 text-base">
              <Link href="/create">Create Market</Link>
            </Button>
          </div>
        </div>
      </section>

      {/* Stats Banner */}
      <section className="border-y">
        <div className="container py-12 grid grid-cols-1 md:grid-cols-3 gap-8 text-center mx-auto px-4">
          <div>
            <div className="text-4xl font-bold">$2.4M+</div>
            <div className="text-sm text-muted-foreground mt-1">Total Volume</div>
          </div>
          <div>
            <div className="text-4xl font-bold">12,450+</div>
            <div className="text-sm text-muted-foreground mt-1">Hidden Positions</div>
          </div>
          <div>
            <div className="text-4xl font-bold">850+</div>
            <div className="text-sm text-muted-foreground mt-1">Active Markets</div>
          </div>
        </div>
      </section>

      {/* Trending Markets */}
      <section className="container mx-auto px-4">
        <div className="flex items-center justify-between mb-8">
          <h2 className="text-2xl font-bold flex items-center gap-2">
            <TrendingUp className="h-6 w-6" />
            Trending Markets
          </h2>
          <Button variant="ghost" asChild>
            <Link href="/markets">View All</Link>
          </Button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Mock Market Card 1 */}
          <Link href="/markets/1">
            <Card className="hover:border-foreground/20 transition-all cursor-pointer group">
              <CardHeader>
                <div className="text-xs font-medium text-muted-foreground mb-2">CRYPTO</div>
                <CardTitle className="text-lg leading-tight">Will BTC hit $100k by 2025?</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Pool</span>
                    <span className="font-mono font-medium">$45,000</span>
                  </div>
                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span>YES 67%</span>
                      <span>NO 33%</span>
                    </div>
                    <div className="h-2 bg-secondary rounded-full overflow-hidden">
                      <div className="h-full bg-success w-[67%]" />
                    </div>
                  </div>
                  <div className="text-xs text-muted-foreground pt-2 border-t border-border/50">
                    Ends in 5 days • 1,247 hidden positions
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>

          {/* Mock Market Card 2 */}
          <Link href="/markets/2">
            <Card className="hover:border-foreground/20 transition-all cursor-pointer group">
              <CardHeader>
                <div className="text-xs font-medium text-muted-foreground mb-2">SPORTS</div>
                <CardTitle className="text-lg leading-tight">Will Liverpool win the Premier League?</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Pool</span>
                    <span className="font-mono font-medium">$12,450</span>
                  </div>
                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span>YES 58%</span>
                      <span>NO 42%</span>
                    </div>
                    <div className="h-2 bg-secondary rounded-full overflow-hidden">
                      <div className="h-full bg-success w-[58%]" />
                    </div>
                  </div>
                  <div className="text-xs text-muted-foreground pt-2 border-t border-border/50">
                    Ends Dec 15, 2024 • 253 hidden positions
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>

          {/* Mock Market Card 3 */}
          <Link href="/markets/3">
            <Card className="hover:border-foreground/20 transition-all cursor-pointer group">
              <CardHeader>
                <div className="text-xs font-medium text-muted-foreground mb-2">POLITICS</div>
                <CardTitle className="text-lg leading-tight">US Election 2028: Will it be a Democrat?</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Pool</span>
                    <span className="font-mono font-medium">$156,000</span>
                  </div>
                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span>YES 45%</span>
                      <span>NO 55%</span>
                    </div>
                    <div className="h-2 bg-secondary rounded-full overflow-hidden">
                      <div className="h-full bg-success w-[45%]" />
                    </div>
                  </div>
                  <div className="text-xs text-muted-foreground pt-2 border-t border-border/50">
                    Ends Nov 2028 • 5,420 hidden positions
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>
        </div>
      </section>

      {/* How it works */}
      <section className="container mx-auto px-4 py-12">
        <h2 className="text-2xl font-bold text-center mb-12">How Chrono Shield Works</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="flex flex-col items-center text-center p-6 rounded-xl bg-card border">
            <div className="h-12 w-12 rounded-full bg-muted flex items-center justify-center mb-4">
              <Lock className="h-6 w-6" />
            </div>
            <h3 className="text-xl font-semibold mb-2">1. Place Private Bet</h3>
            <p className="text-muted-foreground">
              Your position is encrypted and hidden. No one knows which side you picked.
            </p>
          </div>
          <div className="flex flex-col items-center text-center p-6 rounded-xl bg-card border">
            <div className="h-12 w-12 rounded-full bg-muted flex items-center justify-center mb-4">
              <Shield className="h-6 w-6" />
            </div>
            <h3 className="text-xl font-semibold mb-2">2. Wait for Resolution</h3>
            <p className="text-muted-foreground">
              Market closes and the real-world outcome is verified by oracles.
            </p>
          </div>
          <div className="flex flex-col items-center text-center p-6 rounded-xl bg-card border">
            <div className="h-12 w-12 rounded-full bg-muted flex items-center justify-center mb-4">
              <Trophy className="h-6 w-6" />
            </div>
            <h3 className="text-xl font-semibold mb-2">3. Reveal & Win</h3>
            <p className="text-muted-foreground">
              Reveal your position to prove you won and claim your winnings automatically.
            </p>
          </div>
        </div>
      </section>
    </div>
  )
}
