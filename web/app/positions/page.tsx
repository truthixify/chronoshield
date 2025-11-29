'use client'

import { useState } from "react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { ArrowLeft, Lock, LockOpen, Trophy, AlertCircle } from "lucide-react"

export default function PositionsPage() {
    const [activeTab, setActiveTab] = useState<'active' | 'reveal' | 'history'>('active')

    const mockPositions = {
        active: [
            {
                id: 'CM-00147',
                market: 'Will BTC hit $100k by 2025?',
                position: 'YES',
                amount: '0.5 ETH',
                status: 'hidden',
                marketStatus: 'Active',
                endsIn: '15 days',
                category: 'CRYPTO'
            },
            {
                id: 'CM-00156',
                market: 'Will Liverpool win the Premier League?',
                position: 'NO',
                amount: '0.3 ETH',
                status: 'hidden',
                marketStatus: 'Active',
                endsIn: '45 days',
                category: 'SPORTS'
            }
        ],
        reveal: [
            {
                id: 'CM-00122',
                market: 'Will ETH flip BTC by end of 2025?',
                position: 'NO',
                amount: '0.5 ETH',
                outcome: 'NO',
                status: 'not-revealed',
                deadline: '18 hours',
                category: 'CRYPTO',
                result: 'won'
            }
        ],
        history: [
            {
                id: 'CM-00098',
                market: 'US Election 2024: Democrat win?',
                position: 'YES',
                amount: '1.0 ETH',
                outcome: 'YES',
                payout: '1.85 ETH',
                profit: '+0.85 ETH',
                result: 'won',
                category: 'POLITICS'
            },
            {
                id: 'CM-00076',
                market: 'Will SOL reach $200 in Q1 2024?',
                position: 'YES',
                amount: '0.4 ETH',
                outcome: 'NO',
                result: 'lost',
                category: 'CRYPTO'
            }
        ]
    }

    return (
        <div className="container mx-auto px-4 py-8">
            <div className="mb-8">
                <h1 className="text-3xl font-bold mb-2">My Positions</h1>
                <p className="text-muted-foreground">Track all your prediction market bets</p>
            </div>

            {/* Tabs */}
            <div className="flex gap-2 mb-6 border-b">
                <button
                    onClick={() => setActiveTab('active')}
                    className={`px-4 py-2 font-medium transition-colors border-b-2 ${activeTab === 'active'
                            ? 'border-primary text-primary'
                            : 'border-transparent text-muted-foreground hover:text-foreground'
                        }`}
                >
                    Active ({mockPositions.active.length})
                </button>
                <button
                    onClick={() => setActiveTab('reveal')}
                    className={`px-4 py-2 font-medium transition-colors border-b-2 ${activeTab === 'reveal'
                            ? 'border-primary text-primary'
                            : 'border-transparent text-muted-foreground hover:text-foreground'
                        }`}
                >
                    Pending Reveal ({mockPositions.reveal.length})
                </button>
                <button
                    onClick={() => setActiveTab('history')}
                    className={`px-4 py-2 font-medium transition-colors border-b-2 ${activeTab === 'history'
                            ? 'border-primary text-primary'
                            : 'border-transparent text-muted-foreground hover:text-foreground'
                        }`}
                >
                    History ({mockPositions.history.length})
                </button>
            </div>

            {/* Active Positions */}
            {activeTab === 'active' && (
                <div className="space-y-4">
                    {mockPositions.active.map((position) => (
                        <Card key={position.id} className="hover:border-primary/50 transition-colors">
                            <CardHeader>
                                <div className="flex items-start justify-between">
                                    <div className="flex-1">
                                        <div className="text-xs font-medium text-accent mb-2">{position.category}</div>
                                        <CardTitle className="text-lg leading-tight mb-3">{position.market}</CardTitle>
                                    </div>
                                </div>
                            </CardHeader>
                            <CardContent>
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                                    <div>
                                        <div className="text-xs text-muted-foreground mb-1">Your Position</div>
                                        <div className="font-medium flex items-center gap-2">
                                            {position.position} • {position.amount}
                                            <Lock className="h-3 w-3 text-muted-foreground" />
                                        </div>
                                    </div>
                                    <div>
                                        <div className="text-xs text-muted-foreground mb-1">Status</div>
                                        <div className="font-medium">🔒 Hidden</div>
                                    </div>
                                    <div>
                                        <div className="text-xs text-muted-foreground mb-1">Market Status</div>
                                        <div className="font-medium">{position.marketStatus} ({position.endsIn} left)</div>
                                    </div>
                                </div>
                                <div className="text-xs text-muted-foreground mb-3 p-3 bg-muted/30 rounded">
                                    <strong>Commitment ID:</strong> {position.id}
                                </div>
                                <Button variant="outline" size="sm" asChild>
                                    <Link href="/markets/1">View Market</Link>
                                </Button>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}

            {/* Pending Reveal */}
            {activeTab === 'reveal' && (
                <div className="space-y-4">
                    {mockPositions.reveal.map((position) => (
                        <Card key={position.id} className="border-accent/50">
                            <CardHeader>
                                <div className="flex items-start justify-between">
                                    <div className="flex-1">
                                        <div className="text-xs font-medium text-accent mb-2">{position.category}</div>
                                        <CardTitle className="text-lg leading-tight mb-2">{position.market}</CardTitle>
                                        <div className="flex items-center gap-2 text-sm">
                                            <span className="px-2 py-1 bg-success/20 text-success rounded">
                                                🏆 MARKET RESOLVED - Winning Outcome: {position.outcome}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </CardHeader>
                            <CardContent>
                                <div className="mb-4 p-4 bg-accent/10 border border-accent/30 rounded-lg">
                                    <div className="flex items-start gap-3">
                                        <AlertCircle className="h-5 w-5 text-accent mt-0.5" />
                                        <div className="flex-1">
                                            <div className="font-semibold mb-1">Action Required: Reveal Your Position</div>
                                            <div className="text-sm text-muted-foreground">
                                                You have {position.deadline} to reveal your position and claim potential winnings.
                                                After the deadline, your position will be forfeited.
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                                    <div>
                                        <div className="text-xs text-muted-foreground mb-1">Your Position</div>
                                        <div className="font-medium">🔒 Not Revealed Yet</div>
                                    </div>
                                    <div>
                                        <div className="text-xs text-muted-foreground mb-1">Commitment ID</div>
                                        <div className="font-mono text-sm">{position.id}</div>
                                    </div>
                                </div>

                                <Button className="w-full" size="lg">
                                    <LockOpen className="mr-2 h-4 w-4" />
                                    Reveal Position & Claim Winnings
                                </Button>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}

            {/* History */}
            {activeTab === 'history' && (
                <div className="space-y-4">
                    {mockPositions.history.map((position) => (
                        <Card key={position.id}>
                            <CardHeader>
                                <div className="flex items-start justify-between">
                                    <div className="flex-1">
                                        <div className="text-xs font-medium text-accent mb-2">{position.category}</div>
                                        <CardTitle className="text-lg leading-tight">{position.market}</CardTitle>
                                    </div>
                                    {position.result === 'won' ? (
                                        <Trophy className="h-5 w-5 text-success" />
                                    ) : (
                                        <div className="text-destructive text-sm font-medium">Lost</div>
                                    )}
                                </div>
                            </CardHeader>
                            <CardContent>
                                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                    <div>
                                        <div className="text-xs text-muted-foreground mb-1">Your Bet</div>
                                        <div className="font-medium">{position.position} • {position.amount}</div>
                                    </div>
                                    <div>
                                        <div className="text-xs text-muted-foreground mb-1">Outcome</div>
                                        <div className="font-medium">{position.outcome}</div>
                                    </div>
                                    {position.result === 'won' ? (
                                        <>
                                            <div>
                                                <div className="text-xs text-muted-foreground mb-1">Payout</div>
                                                <div className="font-medium font-mono">{position.payout}</div>
                                            </div>
                                            <div>
                                                <div className="text-xs text-muted-foreground mb-1">Profit</div>
                                                <div className="font-medium font-mono text-success">{position.profit}</div>
                                            </div>
                                        </>
                                    ) : (
                                        <div className="col-span-2">
                                            <div className="text-xs text-muted-foreground mb-1">Result</div>
                                            <div className="font-medium text-destructive">Position Lost</div>
                                        </div>
                                    )}
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}
        </div>
    )
}
