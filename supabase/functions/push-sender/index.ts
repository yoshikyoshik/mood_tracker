import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// FIX 1: Wir sagen explizit, dass 'req' ein Request-Objekt ist
Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { record } = await req.json()
    
    if (!record || !record.receiver_profile_id || !record.ping_type) {
      return new Response("Keine relevanten Daten", { status: 200 })
    }

    console.log(`🔔 Neuer Ping! Typ: ${record.ping_type}, Empfänger: ${record.receiver_profile_id}`)

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { data: profile, error: profileError } = await supabaseClient
      .from('profiles')
      .select('onesignal_id, name')
      .eq('id', record.receiver_profile_id)
      .single()

    if (profileError || !profile || !profile.onesignal_id) {
      console.log("❌ Empfänger hat keine Push-ID oder nicht gefunden.")
      return new Response("Empfänger nicht erreichbar", { status: 200 })
    }

    let msgContent = "Denkt an dich!"
    let msgTitle = "Neues Signal ❤️"
    
    if (record.ping_type === 'hug') { msgTitle = "Eine Umarmung 🤗"; msgContent = "Fühl dich gedrückt!"; }
    else if (record.ping_type === 'energy') { msgTitle = "Energie 🔥"; msgContent = "Du schaffst das!"; }
    else if (record.ping_type === 'poke') { msgTitle = "Huhu! 👻"; msgContent = "Ich denk an dich."; }
    else if (record.ping_type === 'love') { msgTitle = "Liebe ❤️"; msgContent = "Ich liebe dich!"; }

    console.log(`🚀 Sende Push an ${profile.name} (${profile.onesignal_id})...`)

    const oneSignalAppId = Deno.env.get('ONESIGNAL_APP_ID')
    const oneSignalApiKey = Deno.env.get('ONESIGNAL_API_KEY')

    const response = await fetch("https://onesignal.com/api/v1/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": `Basic ${oneSignalApiKey}`
      },
      body: JSON.stringify({
        app_id: oneSignalAppId,
        include_player_ids: [profile.onesignal_id],
        headings: { en: msgTitle },
        contents: { en: msgContent },
        android_group: "mood_pings"
      })
    })

    const result = await response.json()
    console.log("✅ OneSignal Antwort:", result)

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  // FIX 2: Wir definieren error als 'any', damit wir auf .message zugreifen dürfen
  } catch (error: any) {
    console.error("💥 Fehler:", error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})