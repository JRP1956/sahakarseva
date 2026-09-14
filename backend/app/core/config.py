from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    database_url: str = "postgresql+psycopg://gig:gig@localhost:5433/gig"
    test_database_url: str = "postgresql+psycopg://gig:gig@localhost:5433/gig_test"
    jwt_secret: str = "dev-secret"
    razorpay_key_id: str = ""
    razorpay_key_secret: str = ""
    demo_mark_paid: bool = True
    upload_dir: str = "uploads"
    model_config = SettingsConfigDict(env_file=".env")


settings = Settings()
