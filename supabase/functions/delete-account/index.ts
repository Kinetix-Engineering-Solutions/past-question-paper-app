import { createClient } from 'npm:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

function jsonResponse(
  body: Record<string, unknown>,
  status: number,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  })
}

Deno.serve(async (request: Request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (request.method !== 'POST') {
    return jsonResponse(
      { message: 'Method not allowed.' },
      405,
    )
  }

  const authorization =
    request.headers.get('Authorization')

  if (
    authorization == null ||
    !authorization.startsWith('Bearer ')
  ) {
    return jsonResponse(
      { message: 'Authentication is required.' },
      401,
    )
  }

  const supabaseUrl =
    Deno.env.get('SUPABASE_URL')
  const anonKey =
    Deno.env.get('SUPABASE_ANON_KEY')
  const serviceRoleKey =
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

  if (
    !supabaseUrl ||
    !anonKey ||
    !serviceRoleKey
  ) {
    console.error(
      'Required Supabase environment variables are missing.',
    )

    return jsonResponse(
      { message: 'Server configuration error.' },
      500,
    )
  }

  let payload: { confirmation?: unknown }

  try {
    payload = await request.json()
  } catch {
    return jsonResponse(
      { message: 'Invalid request body.' },
      400,
    )
  }

  if (payload.confirmation !== 'DELETE') {
    return jsonResponse(
      {
        message:
          'Type DELETE to confirm account deletion.',
      },
      400,
    )
  }

  const userClient = createClient(
    supabaseUrl,
    anonKey,
    {
      global: {
        headers: {
          Authorization: authorization,
        },
      },
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    },
  )

  const {
    data: { user },
    error: userError,
  } = await userClient.auth.getUser()

  if (userError || user == null) {
    return jsonResponse(
      { message: 'Invalid or expired session.' },
      401,
    )
  }

  const adminClient = createClient(
    supabaseUrl,
    serviceRoleKey,
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    },
  )

  const { error: deleteError } =
    await adminClient.auth.admin.deleteUser(
      user.id,
      false,
    )

  if (deleteError) {
    console.error(
      'Account deletion failed:',
      deleteError.message,
    )

    return jsonResponse(
      { message: 'Unable to delete account.' },
      500,
    )
  }

  return jsonResponse(
    {
      deleted: true,
      userId: user.id,
    },
    200,
  )
})