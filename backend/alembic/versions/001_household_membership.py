"""Add invitations and non-destructive membership revocation.

The project previously initialized tables via create_all without revisions.
This baseline supports those databases and fresh installations.
"""

from alembic import op
import sqlalchemy as sa

revision = "001_household_membership"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    from app.database import Base

    bind = op.get_bind()
    Base.metadata.create_all(bind)
    columns = {column["name"] for column in sa.inspect(bind).get_columns("household_members")}
    if "is_active" not in columns:
        op.add_column("household_members", sa.Column(
            "is_active", sa.Boolean(), nullable=False, server_default=sa.true(),
        ))


def downgrade():
    op.drop_table("household_invitations")
    op.drop_column("household_members", "is_active")
