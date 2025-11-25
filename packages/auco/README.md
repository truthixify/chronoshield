# Auco

A simple Express server for indexing Starknet data.

## Features

- Express server with TypeScript
- Health check endpoints
- CORS enabled
- Security headers with Helmet
- Request logging with Morgan
- Error handling middleware
- Example indexing endpoint

## Setup

1. Install dependencies:
```bash
cd packages/indexer
npm install
```

2. Build the project:
```bash
npm run build
```

## Development

Start the development server with hot reload:
```bash
npm run watch
```

Or run directly with ts-node:
```bash
npm run dev
```

## Production

Build and start the production server:
```bash
npm run build
npm start
```

## API Endpoints

- `GET /` - API information
- `GET /health` - Health check
- `GET /status` - Service status
- `GET /api/index/:address` - Example indexing endpoint

## Environment Variables

- `PORT` - Server port (default: 3001)
- `NODE_ENV` - Environment (development/production)

## Example Usage

```bash
# Start the server
npm run dev

# Test endpoints
curl http://localhost:3001/health
curl http://localhost:3001/api/index/0x123...
``` 