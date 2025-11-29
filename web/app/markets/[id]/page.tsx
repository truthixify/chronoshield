'use client'

import { useState } from "react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { ArrowLeft, TrendingUp, TrendingDown, Users, Calendar, Shield, ExternalLink } from "lucide-react"
import { LineChart, Line, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

// Mock data for the chart
const mockPriceHistory = [
    { time: '12/01', yes: 45, no: 55 },
    { time: '12/05', yes: 52, no: 48 },
    { time: '12/10', yes: 58, no: 42 },
    { time: '12/15', yes: 63, no: 37 },
    { time: '12/20', yes: 67, no: 33 },
    { time: '12/25', yes: 65, no: 35 },
    { time: 'Now', yes: 67, no: 33 },
]

export default function MarketDetailPage() {
    const [selectedOutcome, setSelectedOutcome] = useState<'YES' | 'NO' | null>(null)
    const [betAmount, setBetAmount] = useState("")
    const [timeRange, setTimeRange] = useState("ALL")

    return (
        <div className="container mx-auto px-4 py-8">
            {/* Back Button */}
            <Button variant="ghost" asChild className="mb-4">
                <Link href="/markets">
                    <ArrowLeft className="mr-2 h-4 w-4" />
                    Back to Markets
                </Link>
            </Button>

            {/* Market Question */}
            <div className="mb-6">
                <div className="text-xs font-medium text-accent mb-2">CRYPTO</div>
                <h1 className="text-3xl font-bold mb-2">Will BTC hit $100k by 2025?</h1>
                <div className="flex items-center gap-4 text-sm text-muted-foreground">
                    <span className="flex items-center gap-1">
                        <Calendar className="h-3 w-3" />
                        Ends in 5 days (Dec 31, 2024)
                    </span>
                    <span className="flex items-center gap-1">
                        <Users className="h-3 w-3" />
                        1,247 hidden positions
                    </span>
                    <span>Created by 0x742d...3f2a</span>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Main Content */}
                <div className="lg:col-span-2 space-y-6">
                    {/* Status Card */}
                    <Card>
                        <CardHeader>
                            <CardTitle className="text-lg">Market Status</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                <div>
                                    <div className="text-xs text-muted-foreground mb-1">Status</div>
                                    <div className="font-semibold text-success">ACTIVE</div>
                                </div>
                                <div>
                                    <div className="text-xs text-muted-foreground mb-1">Total Pool</div>
                                    <div className="font-mono font-semibold">$45,000</div>
                                </div>
                                <div>
                                    <div className="text-xs text-muted-foreground mb-1">24h Volume</div>
                                    <div className="font-mono font-semibold">$8,450</div>
                                </div>
                                <div>
                                    <div className="text-xs text-muted-foreground mb-1">Positions</div>
                                    <div className="font-semibold">1,247</div>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Price Chart */}
                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-6">
                            <CardTitle className="text-lg font-medium">Probability Over Time</CardTitle>
                            <div className="flex items-center rounded-lg border bg-muted/50 p-1">
                                {['1H', '1D', '1W', '1M', 'ALL'].map((range) => (
                                    <button
                                        key={range}
                                        onClick={() => setTimeRange(range)}
                                        className={`px-3 py-1 text-xs font-medium rounded-md transition-all ${timeRange === range
                                            ? 'bg-background text-foreground shadow-sm'
                                            : 'text-muted-foreground hover:text-foreground hover:bg-background/50'
                                            }`}
                                    >
                                        {range}
                                    </button>
                                ))}
                            </div>
                        </CardHeader>
                        <CardContent>
                            <div className="h-[350px] w-full">
                                <ResponsiveContainer width="100%" height="100%">
                                    <AreaChart data={mockPriceHistory} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                                        <defs>
                                            <linearGradient id="colorYes" x1="0" y1="0" x2="0" y2="1">
                                                <stop offset="5%" stopColor="hsl(var(--success))" stopOpacity={0.2} />
                                                <stop offset="95%" stopColor="hsl(var(--success))" stopOpacity={0} />
                                            </linearGradient>
                                            <linearGradient id="colorNo" x1="0" y1="0" x2="0" y2="1">
                                                <stop offset="5%" stopColor="hsl(var(--danger))" stopOpacity={0.2} />
                                                <stop offset="95%" stopColor="hsl(var(--danger))" stopOpacity={0} />
                                            </linearGradient>
                                        </defs>
                                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="hsl(var(--border))" />
                                        <XAxis
                                            dataKey="time"
                                            stroke="hsl(var(--muted-foreground))"
                                            fontSize={12}
                                            tickLine={false}
                                            axisLine={false}
                                            dy={10}
                                        />
                                        <YAxis
                                            stroke="hsl(var(--muted-foreground))"
                                            domain={[0, 100]}
                                            fontSize={12}
                                            tickLine={false}
                                            axisLine={false}
                                            dx={-10}
                                            tickFormatter={(value) => `${value}%`}
                                        />
                                        <Tooltip
                                            contentStyle={{
                                                backgroundColor: 'hsl(var(--popover))',
                                                border: '1px solid hsl(var(--border))',
                                                borderRadius: 'var(--radius)',
                                                color: 'hsl(var(--popover-foreground))',
                                                boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
                                            }}
                                            itemStyle={{ fontSize: '12px', fontWeight: 500 }}
                                            labelStyle={{ fontSize: '12px', color: 'hsl(var(--muted-foreground))', marginBottom: '8px' }}
                                        />
                                        <Area
                                            type="monotone"
                                            dataKey="yes"
                                            stroke="hsl(var(--success))"
                                            strokeWidth={2}
                                            fillOpacity={1}
                                            fill="url(#colorYes)"
                                            name="YES"
                                            activeDot={{ r: 4, strokeWidth: 0 }}
                                        />
                                        <Area
                                            type="monotone"
                                            dataKey="no"
                                            stroke="hsl(var(--danger))"
                                            strokeWidth={2}
                                            fillOpacity={1}
                                            fill="url(#colorNo)"
                                            name="NO"
                                            activeDot={{ r: 4, strokeWidth: 0 }}
                                        />
                                    </AreaChart>
                                </ResponsiveContainer>
                            </div>
                            <div className="flex items-center justify-center gap-8 mt-6">
                                <div className="flex items-center gap-2">
                                    <div className="flex items-center justify-center w-4 h-4 rounded-full bg-success/20">
                                        <div className="w-2 h-2 bg-success rounded-full" />
                                    </div>
                                    <span className="text-sm font-medium">YES Probability</span>
                                </div>
                                <div className="flex items-center gap-2">
                                    <div className="flex items-center justify-center w-4 h-4 rounded-full bg-danger/20">
                                        <div className="w-2 h-2 bg-danger rounded-full" />
                                    </div>
                                    <span className="text-sm font-medium">NO Probability</span>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Market Info */}
                    <Card>
                        <CardHeader>
                            <CardTitle className="text-lg">Market Information</CardTitle>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div>
                                <div className="text-sm font-semibold mb-2">Resolution Criteria</div>
                                <p className="text-sm text-muted-foreground">
                                    This market will resolve to YES if Bitcoin (BTC) reaches a price of $100,000 USD or higher
                                    on any major exchange (Coinbase, Binance, Kraken) before January 1, 2025, 00:00 UTC.
                                    Otherwise, it resolves to NO.
                                </p>
                            </div>
                            <div className="grid grid-cols-2 gap-4 pt-4 border-t">
                                <div>
                                    <div className="text-xs text-muted-foreground mb-1">Resolution Source</div>
                                    <div className="text-sm font-medium">Chainlink Oracle</div>
                                </div>
                                <div>
                                    <div className="text-xs text-muted-foreground mb-1">Resolution Date</div>
                                    <div className="text-sm font-medium">Jan 1, 2025</div>
                                </div>
                                <div>
                                    <div className="text-xs text-muted-foreground mb-1">Creator</div>
                                    <div className="text-sm font-mono">0x742d...3f2a</div>
                                </div>
                                <div>
                                    <div className="text-xs text-muted-foreground mb-1">Market ID</div>
                                    <div className="text-sm font-mono">#MKT-0042</div>
                                </div>
                            </div>
                            <div className="pt-4 border-t">
                                <Button variant="outline" size="sm" className="w-full">
                                    <ExternalLink className="mr-2 h-3 w-3" />
                                    View on Block Explorer
                                </Button>
                            </div>
                        </CardContent>
                    </Card>
                </div>

                {/* Betting Sidebar */}
                <div className="lg:col-span-1">
                    <Card className="sticky top-20">
                        <CardHeader>
                            <CardTitle className="text-lg">Place Your Bet (Private)</CardTitle>
                            <div className="flex items-center gap-2 text-xs text-muted-foreground">
                                <Shield className="h-3 w-3" />
                                Your position will be hidden until market resolves
                            </div>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            {/* Outcome Selection */}
                            <div className="grid grid-cols-2 gap-3">
                                <button
                                    onClick={() => setSelectedOutcome('YES')}
                                    className={`p-4 rounded-lg border-2 transition-all ${selectedOutcome === 'YES'
                                        ? 'border-success bg-success/10'
                                        : 'border-border hover:border-success/50'
                                        }`}
                                >
                                    <div className="text-2xl font-bold text-success mb-1">67%</div>
                                    <div className="text-sm font-medium">YES</div>
                                    <div className="text-xs text-muted-foreground mt-1">
                                        <TrendingUp className="h-3 w-3 inline mr-1" />
                                        +2%
                                    </div>
                                </button>
                                <button
                                    onClick={() => setSelectedOutcome('NO')}
                                    className={`p-4 rounded-lg border-2 transition-all ${selectedOutcome === 'NO'
                                        ? 'border-destructive bg-destructive/10'
                                        : 'border-border hover:border-destructive/50'
                                        }`}
                                >
                                    <div className="text-2xl font-bold text-destructive mb-1">33%</div>
                                    <div className="text-sm font-medium">NO</div>
                                    <div className="text-xs text-muted-foreground mt-1">
                                        <TrendingDown className="h-3 w-3 inline mr-1" />
                                        -2%
                                    </div>
                                </button>
                            </div>

                            {/* Amount Input */}
                            <div className="space-y-2">
                                <label className="text-sm font-medium">Bet Amount</label>
                                <div className="relative">
                                    <Input
                                        type="number"
                                        step="0.01"
                                        placeholder="0.00"
                                        value={betAmount}
                                        onChange={(e) => setBetAmount(e.target.value)}
                                        className="pr-12"
                                        disabled={!selectedOutcome}
                                    />
                                    <span className="absolute right-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">
                                        ETH
                                    </span>
                                </div>
                            </div>

                            {/* Potential Payout */}
                            {betAmount && selectedOutcome && (
                                <div className="p-4 bg-muted/30 rounded-lg space-y-2">
                                    <div className="flex justify-between text-sm">
                                        <span className="text-muted-foreground">Potential Payout</span>
                                        <span className="font-mono font-medium">
                                            {(parseFloat(betAmount) * (selectedOutcome === 'YES' ? 1.49 : 3.03)).toFixed(3)} ETH
                                        </span>
                                    </div>
                                    <div className="flex justify-between text-sm">
                                        <span className="text-muted-foreground">Potential Profit</span>
                                        <span className="font-mono font-medium text-success">
                                            +{(parseFloat(betAmount) * (selectedOutcome === 'YES' ? 0.49 : 2.03)).toFixed(3)} ETH
                                        </span>
                                    </div>
                                </div>
                            )}

                            {/* Privacy Notice */}
                            <div className="p-3 bg-primary/10 border border-primary/30 rounded-lg">
                                <div className="flex gap-2 text-xs">
                                    <Shield className="h-4 w-4 text-primary flex-shrink-0 mt-0.5" />
                                    <div className="text-muted-foreground">
                                        <strong className="text-foreground">Privacy Protected:</strong> Your position will be encrypted and hidden from all other users until the market resolves.
                                    </div>
                                </div>
                            </div>

                            {/* Confirm Button */}
                            <Button
                                className="w-full"
                                size="lg"
                                disabled={!selectedOutcome || !betAmount || parseFloat(betAmount) <= 0}
                            >
                                Confirm Bet
                            </Button>

                            <p className="text-xs text-center text-muted-foreground">
                                By placing a bet, you agree to the market resolution criteria
                            </p>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </div>
    )
}
