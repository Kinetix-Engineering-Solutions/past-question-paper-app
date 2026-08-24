# Supabase database migrations

This directory owns the Flutter application's Supabase objects in the
`public` schema.

These include:

- learner profiles;
- question bookmarks and progress;
- question comments;
- comment reports and user blocks;
- Community Guidelines acceptance;
- related RLS configuration, triggers and RPC functions.

## Schema ownership

The database has two separate owners:

- `PastPapers.ContentApi` EF Core migrations own the `content` schema and
  `public.__EFMigrationsHistory`.
- This Supabase migration directory owns the learner-data objects in the
  `public` schema.

Public tables and functions intentionally reference `content.questions`
and `content.topics`.

## Required migration order

For a new database:

1. Apply the `PastPapers.ContentApi` EF Core migrations.
2. Apply the Supabase migrations in this directory.

The content schema must exist before the public-schema baseline is applied
because public foreign keys reference content tables.

## Production safety

Never run either of these commands against the linked production project:

```text
npx supabase db reset --linked
npx supabase db reset --db-url ...