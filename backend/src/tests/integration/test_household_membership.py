"""Membership lifecycle, permissions, and preservation of existing household data."""

from datetime import datetime, timedelta, timezone
import uuid

import pytest
import pytest_asyncio
from sqlalchemy import select

from app.households.models import HouseholdInvitation, HouseholdMember


@pytest_asyncio.fixture
async def owner_headers(auth_headers, test_user, db_session):
    test_user[2].role = 'owner'
    await db_session.flush()
    return auth_headers


async def invite_and_join(client, owner_headers, auth_headers_2, test_user_2, test_user, role='member'):
    response = await client.post('/api/v1/household/invitations',
        headers=owner_headers, json={'email': test_user_2[0].email, 'role': role})
    assert response.status_code == 201, response.text
    invitation = response.json()
    response = await client.post(f"/api/v1/household/invitations/{invitation['id']}/accept",
        headers=auth_headers_2)
    assert response.status_code == 200, response.text
    return invitation, {**auth_headers_2, 'X-Household-ID': str(test_user[1].id)}


@pytest.mark.asyncio
async def test_join_switch_and_personal_inventory_preserved(client, owner_headers, auth_headers_2,
        test_user, test_user_2, inventory_items):
    invitation, shared_headers = await invite_and_join(client, owner_headers, auth_headers_2, test_user_2, test_user)
    available = await client.get('/api/v1/household/available', headers=auth_headers_2)
    assert {h['id'] for h in available.json()} == {str(test_user[1].id), str(test_user_2[1].id)}
    items = await client.get('/api/v1/inventory-items', headers=shared_headers)
    assert items.status_code == 200
    assert len(items.json()['items']) == 3
    personal = await client.get('/api/v1/inventory-items', headers=auth_headers_2)
    assert personal.json()['items'] == []
    members = await client.get('/api/v1/household/members', headers=shared_headers)
    assert {m['email'] for m in members.json()} == {test_user[0].email, test_user_2[0].email}
    repeat = await client.post(f"/api/v1/household/invitations/{invitation['id']}/accept", headers=auth_headers_2)
    assert repeat.status_code == 409


@pytest.mark.asyncio
async def test_uninvited_household_header_is_rejected(client, auth_headers_2, test_user, inventory_items):
    headers = {**auth_headers_2, 'X-Household-ID': str(test_user[1].id)}
    for path in ['/api/v1/household', '/api/v1/household/members', '/api/v1/inventory-items', '/api/v1/storage-locations']:
        response = await client.get(path, headers=headers)
        assert response.status_code == 404


@pytest.mark.asyncio
async def test_invitation_recipient_and_duplicate_checks(client, owner_headers, auth_headers_2, test_user_2):
    data = {'email': test_user_2[0].email.upper(), 'role': 'member'}
    response = await client.post('/api/v1/household/invitations', headers=owner_headers, json=data)
    assert response.status_code == 201
    invitation_id = response.json()['id']
    duplicate = await client.post('/api/v1/household/invitations', headers=owner_headers, json=data)
    assert duplicate.status_code == 409
    wrong_user = await client.post(f'/api/v1/household/invitations/{invitation_id}/accept', headers=owner_headers)
    assert wrong_user.status_code == 404
    incoming = await client.get('/api/v1/household/invitations/incoming', headers=auth_headers_2)
    assert invitation_id in {i['id'] for i in incoming.json()}
    declined = await client.post(f'/api/v1/household/invitations/{invitation_id}/decline', headers=auth_headers_2)
    assert declined.status_code == 200
    response = await client.post(f'/api/v1/household/invitations/{invitation_id}/accept', headers=auth_headers_2)
    assert response.status_code == 409


@pytest.mark.asyncio
async def test_revoked_and_expired_invitations(client, owner_headers, auth_headers_2, test_user_2, db_session):
    response = await client.post('/api/v1/household/invitations', headers=owner_headers,
        json={'email': test_user_2[0].email})
    invitation_id = response.json()['id']
    response = await client.delete(f'/api/v1/household/invitations/{invitation_id}', headers=owner_headers)
    assert response.status_code == 204
    response = await client.post(f'/api/v1/household/invitations/{invitation_id}/accept', headers=auth_headers_2)
    assert response.status_code == 409
    response = await client.post('/api/v1/household/invitations', headers=owner_headers,
        json={'email': test_user_2[0].email})
    invitation_id = response.json()['id']
    invite = await db_session.get(HouseholdInvitation, uuid.UUID(invitation_id))
    invite.expires_at = datetime.now(timezone.utc) - timedelta(days=1)
    await db_session.flush()
    response = await client.post(f'/api/v1/household/invitations/{invitation_id}/accept', headers=auth_headers_2)
    assert response.status_code == 409


@pytest.mark.asyncio
async def test_member_permissions_and_owner_protection(client, owner_headers, auth_headers_2,
        test_user, test_user_2, db_session):
    _, shared_headers = await invite_and_join(client, owner_headers, auth_headers_2, test_user_2, test_user)
    for method, path, data in [
        ('post', '/api/v1/household/invitations', {'email': 'other@example.com'}),
        ('patch', '/api/v1/household', {'name': 'Unauthorized rename'}),
        ('patch', f'/api/v1/household/members/{test_user[2].id}', {'role': 'admin'}),
    ]:
        response = await getattr(client, method)(path, headers=shared_headers, json=data)
        assert response.status_code == 403
    response = await client.delete(f'/api/v1/household/members/{test_user[2].id}', headers=owner_headers)
    assert response.status_code == 403
    response = await client.patch(f'/api/v1/household/members/{test_user[2].id}',
        headers=owner_headers, json={'role': 'member'})
    assert response.status_code == 403
    # IDs from another household cannot be used to mutate its members.
    response = await client.delete(f'/api/v1/household/members/{test_user_2[2].id}', headers=owner_headers)
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_admin_permissions_and_role_changes(client, owner_headers, auth_headers_2,
        test_user, test_user_2, db_session):
    _, shared_headers = await invite_and_join(client, owner_headers, auth_headers_2, test_user_2, test_user, 'admin')
    response = await client.patch('/api/v1/household', headers=shared_headers, json={'name': 'Family kitchen'})
    assert response.status_code == 200
    response = await client.post('/api/v1/household/invitations', headers=shared_headers,
        json={'email': 'friend@example.com', 'role': 'admin'})
    assert response.status_code == 403
    response = await client.post('/api/v1/household/invitations', headers=shared_headers,
        json={'email': 'friend@example.com', 'role': 'member'})
    assert response.status_code == 201
    member = await db_session.scalar(select(HouseholdMember).where(
        HouseholdMember.household_id == test_user[1].id, HouseholdMember.user_id == test_user_2[0].id))
    response = await client.patch(f'/api/v1/household/members/{member.id}',
        headers=owner_headers, json={'role': 'member'})
    assert response.status_code == 204
    response = await client.post('/api/v1/household/invitations', headers=shared_headers,
        json={'email': 'other@example.com'})
    assert response.status_code == 403


@pytest.mark.asyncio
async def test_removal_keeps_contributions_and_reinvite_restores_membership(client, owner_headers,
        auth_headers_2, test_user, test_user_2, storage_locations, reference_data, db_session):
    _, shared_headers = await invite_and_join(client, owner_headers, auth_headers_2, test_user_2, test_user)
    item = await client.post('/api/v1/inventory-items', headers=shared_headers, json={
        'name': 'Shared milk', 'category_key': 'dairy', 'quantity': '1', 'unit_key': 'liter',
        'storage_location_id': str(storage_locations[0].id), 'is_homemade': False,
    })
    assert item.status_code == 201, item.text
    location = await client.post('/api/v1/storage-locations', headers=shared_headers,
        json={'name': 'Shared shelf', 'type': 'shelf', 'parent_id': str(storage_locations[0].id)})
    assert location.status_code == 201, location.text
    member = await db_session.scalar(select(HouseholdMember).where(
        HouseholdMember.household_id == test_user[1].id, HouseholdMember.user_id == test_user_2[0].id))
    original_id = member.id
    response = await client.delete(f'/api/v1/household/members/{member.id}', headers=owner_headers)
    assert response.status_code == 204
    response = await client.get('/api/v1/inventory-items', headers=shared_headers)
    assert response.status_code == 404
    response = await client.get(f"/api/v1/inventory-items/{item.json()['id']}", headers=owner_headers)
    assert response.status_code == 200
    assert response.json()['created_by'] == str(original_id)
    response = await client.get(f"/api/v1/storage-locations/{location.json()['id']}", headers=owner_headers)
    assert response.status_code == 200
    _, shared_headers = await invite_and_join(client, owner_headers, auth_headers_2, test_user_2, test_user)
    await db_session.refresh(member)
    assert member.id == original_id
    assert member.is_active
    response = await client.delete(f'/api/v1/household/members/{member.id}', headers=shared_headers)
    assert response.status_code == 204
