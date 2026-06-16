"""Add daily_affirmations table

Revision ID: 22ba7caeeeaf
Revises: 
Create Date: 2026-06-08 12:04:23.359249
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


revision: str = '22ba7caeeeaf'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    op.create_table(
        'daily_affirmations',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('affirmation_text', sa.String(), nullable=False),
        sa.Column('affirmation_date', sa.Date(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column('generated_by', sa.String(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_daily_affirmations_id', 'daily_affirmations', ['id'], unique=False)
    op.create_index('ix_daily_affirmations_affirmation_date', 'daily_affirmations', ['affirmation_date'], unique=True)

def downgrade() -> None:
    op.drop_index('ix_daily_affirmations_affirmation_date', table_name='daily_affirmations')
    op.drop_index('ix_daily_affirmations_id', table_name='daily_affirmations')
    op.drop_table('daily_affirmations')
