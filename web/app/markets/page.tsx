import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Search, Filter } from "lucide-react"

export default function MarketsPage() {
    return (
        <div className="container mx-auto px-4 py-8">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-8">
                <div>
                    <h1 className="text-3xl font-bold">Explore Markets</h1>
                    <p className="text-muted-foreground">Discover and bet on the latest outcomes</p>
                </div>
                <div className="flex gap-2 w-full md:w-auto">
                    <div className="relative w-full md:w-64">
                        <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                        <Input
                            type="search"
                            placeholder="Search markets..."
                            className="pl-8"
                        />
                    </div>
                    <Button variant="outline" size="icon">
                        <Filter className="h-4 w-4" />
                    </Button>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
                {/* Sidebar Filters */}
                <div className="hidden lg:block space-y-6">
                    <div>
                        <h3 className="font-semibold mb-4">Categories</h3>
                        <div className="space-y-2">
                            <Button variant="secondary" className="w-full justify-start">All Categories</Button>
                            <Button variant="ghost" className="w-full justify-start">Crypto</Button>
                            <Button variant="ghost" className="w-full justify-start">Sports</Button>
                            <Button variant="ghost" className="w-full justify-start">Politics</Button>
                            <Button variant="ghost" className="w-full justify-start">Entertainment</Button>
                        </div>
                    </div>
                    <div>
                        <h3 className="font-semibold mb-4">Status</h3>
                        <div className="space-y-2">
                            <div className="flex items-center gap-2">
                                <input type="checkbox" id="active" className="rounded border-gray-300" defaultChecked />
                                <label htmlFor="active" className="text-sm">Active</label>
                            </div>
                            <div className="flex items-center gap-2">
                                <input type="checkbox" id="resolved" className="rounded border-gray-300" />
                                <label htmlFor="resolved" className="text-sm">Resolved</label>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Market Grid */}
                <div className="lg:col-span-3 grid grid-cols-1 md:grid-cols-2 gap-6">
                    {/* Mock Market Card 1 */}
                    <Link href="/markets/1">
                        <Card className="hover:border-primary/50 transition-colors cursor-pointer group">
                            <CardHeader>
                                <div className="text-xs font-medium text-accent mb-2">CRYPTO</div>
                                <CardTitle className="text-lg leading-tight group-hover:text-primary transition-colors">Will BTC hit $100k by 2025?</CardTitle>
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
                        <Card className="hover:border-primary/50 transition-colors cursor-pointer group">
                            <CardHeader>
                                <div className="text-xs font-medium text-accent mb-2">SPORTS</div>
                                <CardTitle className="text-lg leading-tight group-hover:text-primary transition-colors">Will Liverpool win the Premier League?</CardTitle>
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
                        <Card className="hover:border-primary/50 transition-colors cursor-pointer group">
                            <CardHeader>
                                <div className="text-xs font-medium text-accent mb-2">POLITICS</div>
                                <CardTitle className="text-lg leading-tight group-hover:text-primary transition-colors">US Election 2028: Will it be a Democrat?</CardTitle>
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
            </div>
        </div>
    )
}
