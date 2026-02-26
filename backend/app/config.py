import os
from dotenv import load_dotenv

load_dotenv()

# Original PostgreSQL configuration - commented out for local development fallback
# DATABASE_URL = (
#     f"postgresql://{os.getenv('DB_USER')}:"
#     f"{os.getenv('DB_PASSWORD')}@"
#     f"{os.getenv('DB_HOST')}:"
#     f"{os.getenv('DB_PORT')}/"
#     f"{os.getenv('DB_NAME')}"
# )

# Using SQLite as a fallback to ensure the backend can run without a local PostgreSQL instance
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./backend_dev.db")
