"""worker lat/lng

Revision ID: 0002
Revises: 0001
"""
import sqlalchemy as sa
from alembic import op

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("workers", sa.Column("lat", sa.Float(), nullable=True))
    op.add_column("workers", sa.Column("lng", sa.Float(), nullable=True))


def downgrade() -> None:
    op.drop_column("workers", "lng")
    op.drop_column("workers", "lat")
