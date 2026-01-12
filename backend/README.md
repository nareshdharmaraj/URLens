# URLens Backend API

Backend API for URLens - Universal web media downloader

## Setup

1. Create a virtual environment:
```bash
python -m venv venv
```

2. Activate the virtual environment:
- Windows: `venv\Scripts\activate`
- Linux/Mac: `source venv/bin/activate`

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Create `.env` file:
```bash
cp .env.example .env
```

5. Run the server:
```bash
python main.py
```

Or using uvicorn directly:
```bash
uvicorn main:app --reload
```

## API Documentation

Once the server is running, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Endpoints

### POST /api/v1/analyze
Analyze a URL and return metadata (platform, title, thumbnail)

### POST /api/v1/download-info
Get available download options with direct download URLs

## Deployment to Render

1. Push code to GitHub
2. Create new Web Service on Render
3. Connect your GitHub repository
4. Set build command: `pip install -r requirements.txt`
5. Set start command: `uvicorn main:app --host 0.0.0.0 --port $PORT`
6. Add environment variables from `.env.example`
7. Deploy!
