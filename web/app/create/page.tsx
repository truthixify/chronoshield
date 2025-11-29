'use client'

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { Calendar, Sparkles } from "lucide-react"

export default function CreateMarketPage() {
    const [question, setQuestion] = useState("")
    const [category, setCategory] = useState("")
    const [description, setDescription] = useState("")
    const [resolutionDate, setResolutionDate] = useState("")
    const [oracle, setOracle] = useState("chainlink")

    return (
        <div className="container mx-auto px-4 py-8 max-w-3xl">
            <div className="mb-8">
                <h1 className="text-3xl font-bold mb-2">Create New Market</h1>
                <p className="text-muted-foreground">
                    Launch a private prediction market for any future outcome
                </p>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Market Details</CardTitle>
                    <CardDescription>
                        Fill in the information about your prediction market
                    </CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                    <div className="space-y-2">
                        <Label htmlFor="question">Market Question *</Label>
                        <Input
                            id="question"
                            placeholder="e.g., Will X happen by Y date?"
                            value={question}
                            onChange={(e) => setQuestion(e.target.value)}
                        />
                        <p className="text-xs text-muted-foreground">
                            Make it clear and verifiable. Must be answerable with YES or NO.
                        </p>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="category">Category *</Label>
                        <Select value={category} onValueChange={setCategory}>
                            <SelectTrigger id="category">
                                <SelectValue placeholder="Select a category" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="crypto">🪙 Crypto</SelectItem>
                                <SelectItem value="sports">⚽ Sports</SelectItem>
                                <SelectItem value="politics">🗳️ Politics</SelectItem>
                                <SelectItem value="entertainment">🎬 Entertainment</SelectItem>
                                <SelectItem value="technology">💻 Technology</SelectItem>
                                <SelectItem value="other">🔮 Other</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="resolution-date">Resolution Date *</Label>
                        <div className="relative">
                            <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                            <Input
                                id="resolution-date"
                                type="datetime-local"
                                className="pl-10"
                                value={resolutionDate}
                                onChange={(e) => setResolutionDate(e.target.value)}
                            />
                        </div>
                        <p className="text-xs text-muted-foreground">
                            When should this market close and be resolved?
                        </p>
                    </div>

                    <div className="space-y-2">
                        <Label>Resolution Source *</Label>
                        <div className="space-y-3">
                            <div
                                className={`flex items-start space-x-3 p-4 border rounded-lg cursor-pointer transition-colors ${oracle === 'chainlink' ? 'border-primary bg-primary/5' : 'hover:bg-muted/50'
                                    }`}
                                onClick={() => setOracle('chainlink')}
                            >
                                <input
                                    type="radio"
                                    name="oracle"
                                    value="chainlink"
                                    checked={oracle === 'chainlink'}
                                    onChange={(e) => setOracle(e.target.value)}
                                    className="mt-1"
                                />
                                <div className="flex-1">
                                    <div className="font-medium">Chainlink Oracle</div>
                                    <div className="text-sm text-muted-foreground">
                                        Automated resolution using Chainlink data feeds (most reliable)
                                    </div>
                                </div>
                            </div>

                            <div
                                className={`flex items-start space-x-3 p-4 border rounded-lg cursor-pointer transition-colors ${oracle === 'manual' ? 'border-primary bg-primary/5' : 'hover:bg-muted/50'
                                    }`}
                                onClick={() => setOracle('manual')}
                            >
                                <input
                                    type="radio"
                                    name="oracle"
                                    value="manual"
                                    checked={oracle === 'manual'}
                                    onChange={(e) => setOracle(e.target.value)}
                                    className="mt-1"
                                />
                                <div className="flex-1">
                                    <div className="font-medium">Manual Resolution</div>
                                    <div className="text-sm text-muted-foreground">
                                        Requires community verification (7-day dispute period)
                                    </div>
                                </div>
                            </div>

                            <div
                                className={`flex items-start space-x-3 p-4 border rounded-lg cursor-pointer transition-colors ${oracle === 'zkml' ? 'border-primary bg-primary/5' : 'hover:bg-muted/50'
                                    }`}
                                onClick={() => setOracle('zkml')}
                            >
                                <input
                                    type="radio"
                                    name="oracle"
                                    value="zkml"
                                    checked={oracle === 'zkml'}
                                    onChange={(e) => setOracle(e.target.value)}
                                    className="mt-1"
                                />
                                <div className="flex-1 flex items-center gap-2">
                                    <div>
                                        <div className="font-medium flex items-center gap-2">
                                            ZK-ML Oracle
                                            <span className="text-xs px-2 py-0.5 bg-accent/20 text-accent rounded-full">EXPERIMENTAL</span>
                                        </div>
                                        <div className="text-sm text-muted-foreground">
                                            AI-powered verification with zero-knowledge proofs
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="description">Market Description (Optional)</Label>
                        <Textarea
                            id="description"
                            placeholder="Provide additional context, rules, or criteria for resolution..."
                            rows={4}
                            value={description}
                            onChange={(e) => setDescription(e.target.value)}
                        />
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="liquidity">Initial Liquidity (Optional)</Label>
                        <div className="relative">
                            <Input
                                id="liquidity"
                                type="number"
                                step="0.01"
                                placeholder="0.00"
                                className="pr-12"
                            />
                            <span className="absolute right-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">
                                ETH
                            </span>
                        </div>
                        <p className="text-xs text-muted-foreground">
                            Add initial liquidity to bootstrap the market (can improve betting odds)
                        </p>
                    </div>

                    <div className="pt-4 border-t">
                        <div className="flex items-center justify-between mb-2">
                            <span className="text-sm text-muted-foreground">Estimated Cost</span>
                            <span className="font-mono font-medium">0.05 ETH</span>
                        </div>
                        <div className="flex items-center justify-between text-xs text-muted-foreground">
                            <span>Network fees + market creation</span>
                        </div>
                    </div>

                    <div className="flex gap-3 pt-4">
                        <Button variant="outline" className="flex-1">
                            Cancel
                        </Button>
                        <Button
                            className="flex-1"
                            disabled={!question || !category || !resolutionDate}
                        >
                            <Sparkles className="mr-2 h-4 w-4" />
                            Create Market
                        </Button>
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}
