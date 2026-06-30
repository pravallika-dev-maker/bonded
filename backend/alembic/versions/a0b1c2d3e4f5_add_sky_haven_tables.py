"""Add sky haven tables

Revision ID: a0b1c2d3e4f5
Revises: 9f5e6e3eef2b
Create Date: 2026-06-30 14:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a0b1c2d3e4f5'
down_revision: Union[str, None] = '9f5e6e3eef2b'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # sky_haven_islands
    op.create_table('sky_haven_islands',
    sa.Column('id', sa.String(), nullable=False),
    sa.Column('couple_id', sa.Integer(), nullable=True),
    sa.Column('current_turn_user_id', sa.Integer(), nullable=True),
    sa.Column('expansion_stage', sa.Integer(), nullable=True),
    sa.Column('island_version', sa.Integer(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['couple_id'], ['relationships.id'], ),
    sa.ForeignKeyConstraint(['current_turn_user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_sky_haven_islands_couple_id'), 'sky_haven_islands', ['couple_id'], unique=False)
    op.create_index(op.f('ix_sky_haven_islands_id'), 'sky_haven_islands', ['id'], unique=False)

    # sky_haven_assets
    op.create_table('sky_haven_assets',
    sa.Column('id', sa.String(), nullable=False),
    sa.Column('category', sa.String(), nullable=True),
    sa.Column('asset_key', sa.String(), nullable=True),
    sa.Column('display_name', sa.String(), nullable=True),
    sa.Column('unlock_level', sa.Integer(), nullable=True),
    sa.Column('rarity', sa.String(), nullable=True),
    sa.Column('is_active', sa.Boolean(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_sky_haven_assets_asset_key'), 'sky_haven_assets', ['asset_key'], unique=True)
    op.create_index(op.f('ix_sky_haven_assets_category'), 'sky_haven_assets', ['category'], unique=False)
    op.create_index(op.f('ix_sky_haven_assets_id'), 'sky_haven_assets', ['id'], unique=False)

    # placed_island_objects
    op.create_table('placed_island_objects',
    sa.Column('id', sa.String(), nullable=False),
    sa.Column('island_id', sa.String(), nullable=True),
    sa.Column('asset_id', sa.String(), nullable=True),
    sa.Column('placed_by_user_id', sa.Integer(), nullable=True),
    sa.Column('position_x', sa.Float(), nullable=False),
    sa.Column('position_y', sa.Float(), nullable=False),
    sa.Column('rotation', sa.Float(), nullable=True),
    sa.Column('scale', sa.Float(), nullable=True),
    sa.Column('z_index', sa.Integer(), nullable=True),
    sa.Column('whisper', sa.String(), nullable=True),
    sa.Column('has_unread_whisper', sa.Boolean(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['asset_id'], ['sky_haven_assets.id'], ),
    sa.ForeignKeyConstraint(['island_id'], ['sky_haven_islands.id'], ),
    sa.ForeignKeyConstraint(['placed_by_user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_placed_island_objects_id'), 'placed_island_objects', ['id'], unique=False)
    op.create_index(op.f('ix_placed_island_objects_island_id'), 'placed_island_objects', ['island_id'], unique=False)

    # sky_haven_reactions
    op.create_table('sky_haven_reactions',
    sa.Column('id', sa.String(), nullable=False),
    sa.Column('object_id', sa.String(), nullable=True),
    sa.Column('reacted_by_user_id', sa.Integer(), nullable=True),
    sa.Column('reaction', sa.String(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['object_id'], ['placed_island_objects.id'], ),
    sa.ForeignKeyConstraint(['reacted_by_user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_sky_haven_reactions_id'), 'sky_haven_reactions', ['id'], unique=False)
    op.create_index(op.f('ix_sky_haven_reactions_object_id'), 'sky_haven_reactions', ['object_id'], unique=False)

    # sky_haven_milestones
    op.create_table('sky_haven_milestones',
    sa.Column('id', sa.String(), nullable=False),
    sa.Column('island_id', sa.String(), nullable=True),
    sa.Column('milestone_type', sa.String(), nullable=True),
    sa.Column('unlocked_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['island_id'], ['sky_haven_islands.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_sky_haven_milestones_id'), 'sky_haven_milestones', ['id'], unique=False)
    op.create_index(op.f('ix_sky_haven_milestones_island_id'), 'sky_haven_milestones', ['island_id'], unique=False)
    op.create_index(op.f('ix_sky_haven_milestones_milestone_type'), 'sky_haven_milestones', ['milestone_type'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_sky_haven_milestones_milestone_type'), table_name='sky_haven_milestones')
    op.drop_index(op.f('ix_sky_haven_milestones_island_id'), table_name='sky_haven_milestones')
    op.drop_index(op.f('ix_sky_haven_milestones_id'), table_name='sky_haven_milestones')
    op.drop_table('sky_haven_milestones')
    
    op.drop_index(op.f('ix_sky_haven_reactions_object_id'), table_name='sky_haven_reactions')
    op.drop_index(op.f('ix_sky_haven_reactions_id'), table_name='sky_haven_reactions')
    op.drop_table('sky_haven_reactions')
    
    op.drop_index(op.f('ix_placed_island_objects_island_id'), table_name='placed_island_objects')
    op.drop_index(op.f('ix_placed_island_objects_id'), table_name='placed_island_objects')
    op.drop_table('placed_island_objects')
    
    op.drop_index(op.f('ix_sky_haven_assets_id'), table_name='sky_haven_assets')
    op.drop_index(op.f('ix_sky_haven_assets_category'), table_name='sky_haven_assets')
    op.drop_index(op.f('ix_sky_haven_assets_asset_key'), table_name='sky_haven_assets')
    op.drop_table('sky_haven_assets')
    
    op.drop_index(op.f('ix_sky_haven_islands_id'), table_name='sky_haven_islands')
    op.drop_index(op.f('ix_sky_haven_islands_couple_id'), table_name='sky_haven_islands')
    op.drop_table('sky_haven_islands')
